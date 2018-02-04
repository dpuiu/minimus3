#!/bin/bash -eux

ALIGNER=minimap2
MINALIGN=255
export MAXPC=0.05
MINGAP=-1000
MAXGAP=40000
MINID=90		# 90: minimap2 ; 94: minimap2 -a; 97:nucmer
KMER=31
MERGEOUT=merge-1
MERGEPREFIX=merge-1
PREFIX=ref
THREADS=16
MAXTRIM=10000

BIN=/ccb/salz7-data/sw/bin/  
SCRIPT=~dpuiu/bin/minimus3/

#------------------------------------------------------------------------------#

while getopts "A:a:c:g:i:k:M:m:p:t:x:" arg; do
  case $arg in
    A) ALIGNER=$OPTARG  ;;
    a) MINALIGN=$OPTARG ;;
    c) MAXPC=$OPTARG ;;
    g) MAXGAP=$OPTARG ;;
    i) MINID=$OPTARG ;;
    k) KMER=$OPTARG ;;
    M) MERGEOUT=$OPTARG ;;
    m) MERGEPREFIX=$OPTARG ;;
    p) PREFIX=$OPTARG ;;
    t) THREADS=$OPTARG ;;
    x) MAXTRIM=$OPTARG ;;
  esac
done

#------------------------------------------------------------------------------#

test -f ${PREFIX}.fa
test -f ${PREFIX}.len

#align using "bwa mem" or "nucmer -maxmatch" => ${PREFIX}.delta
if [ "$ALIGNER" == "bwa" ] ; then
  if [ ! -s ${PREFIX}.bwt ];        then ${SCRIPT}/bwa index -p ${PREFIX} ${PREFIX}.fa ; fi
  if [ ! -s ${PREFIX}.sam ];        then ${SCRIPT}/bwa mem -k ${KMER} -t ${THREADS} -v 1 -e ${PREFIX} ${PREFIX}.fa | ${SCRIPT}/sam2sam.pl > ${PREFIX}.sam ; fi 
  if [ ! -s ${PREFIX}.srt.sam ];    then grep ^@ ${PREFIX}.sam  >  ${PREFIX}.srt.sam ; egrep -v "^\@|^\[" ${PREFIX}.sam  | sort -k1,1 -k3,3 >> ${PREFIX}.srt.sam ; fi
  if [ ! -s ${PREFIX}.delta   ];    then cat ${PREFIX}.srt.sam | ${SCRIPT}/sam2delta.pl -ni > ${PREFIX}.delta ; fi
elif  [ "$ALIGNER" == "minimap2" ]; then
  if [ ! -s ${PREFIX}.paf   ];      then ${BIN}/minimap2 -k ${KMER} -w5 -Xp0 -m ${MINALIGN} -g10000 --max-chain-skip 25 ${PREFIX}.fa  ${PREFIX}.fa -t ${THREADS} > ${PREFIX}.paf ; fi
  if [ ! -s ${PREFIX}.delta   ];    then cat ${PREFIX}.paf  | sort -k1,1 -k6,6 -k8,8n -k9,9nr | perl -ane ' if(@P and $P[0] eq $F[0] and $P[5] eq $F[5] and $F[8]<=$P[8]) {} else { print ; @P=@F };' | ${SCRIPT}/paf2delta.pl -rf ${PREFIX}.fa -qf ${PREFIX}.fa > ${PREFIX}.delta  ;  fi
elif  [ "$ALIGNER" == "nucmer" ] ;  then
  if [ ! -s ${PREFIX}.delta ];      then ${BIN}/nucmer -t ${THREADS} -l ${KMER} -c ${MINALIGN} --maxmatch --nosimplify ${PREFIX}.fa ${PREFIX}.fa -p ${PREFIX} ; fi
else
  exit 1
fi

##################################################################################################################################################################################

#filter by %identity => ${PREFIX}.filter-i.delta
if [ ! -s ${PREFIX}.filter-i.delta ]; then 
  ${BIN}/delta-filter -i ${MINID} -l ${MINALIGN} ${PREFIX}.delta  | ${SCRIPT}/delta-filter.pl  >  ${PREFIX}.filter-i.delta 
fi

#sort, filter out alignments to itself & contained ones, merge alignments ... => ${PREFIX}.filter.delta
if [ ! -s ${PREFIX}.filter.delta ]; then 
  cat ${PREFIX}.filter-i.delta   | ${SCRIPT}/delta-sort.pl | ${SCRIPT}/delta-filter.pl | \
    ${SCRIPT}/delta-merge.pl -rm ${MINGAP} -rx ${MAXGAP} -qm ${MINGAP} -qx ${MAXGAP} | ${SCRIPT}/delta-filter.pl | \
    ${SCRIPT}/delta-merge.pl -rm ${MINGAP} -rx ${MAXGAP} -qm ${MINGAP} -qx ${MAXGAP} > ${PREFIX}.filter.delta
fi

##################################################################################################################################################################################

#convert to coords and reannotate => ${PREFIX}.filter.coords
if [ ! -s ${PREFIX}.filter.coords ]; then
  ${BIN}/show-coords -l -r -d -L ${MINALIGN} ${PREFIX}.filter.delta | ${SCRIPT}/coords-annotate.pl -p ${MAXPC} -i ${MAXTRIM} -all > ${PREFIX}.filter.coords
fi

#identify CONTAINED sequences
cat ${PREFIX}.filter.coords | egrep "CONTAIN|IDENTITY" | perl -ane 'print $F[16],"\t",$F[6]*$F[9],"\n",$F[17],"\t",$F[7]*$F[9],"\n";'  | ${SCRIPT}/count2.pl -i 0 -j 1 > ${PREFIX}.filter.count
cat ${PREFIX}.filter.coords | grep "CONTAIN"  | ${SCRIPT}/coords2delete.pl > ${PREFIX}.delete
cat ${PREFIX}.filter.coords | grep "IDENTITY" | ${SCRIPT}/difference.pl -i 16 - ${PREFIX}.delete | ${SCRIPT}/difference.pl -i 17 - ${PREFIX}.delete | ${SCRIPT}/join.pl - ${PREFIX}.filter.count -i 16 | ${SCRIPT}/join.pl - ${PREFIX}.filter.count -i 17 | ${SCRIPT}/coords2delete.pl >> ${PREFIX}.delete

#clean coords file
cat ${PREFIX}.filter.coords | ${SCRIPT}/difference.pl -i 16 - ${PREFIX}.delete | ${SCRIPT}/difference.pl -i 17 - ${PREFIX}.delete > ${PREFIX}.clean.coords
cat ${PREFIX}.fa | ${SCRIPT}/fasta-filter.pl -n -f ${PREFIX}.delete > ${PREFIX}.clean.fa

##################################################################################################################################################################################

#identify overlapping sequences => links
cat ${PREFIX}.clean.coords | ${SCRIPT}/coords2link.pl |  sort -nk3 | ${SCRIPT}/uniq2.pl -i 0 -j 1  > ${PREFIX}.link

#exit if no links
if [ ! -s ${PREFIX}.link ] ; then exit 0 ; fi 

#delete ambiguous links
cat ${PREFIX}.link | perl -ane 'print "$F[0]\t$F[2]\n$F[1]\t$F[2]\n";' | perl -ane 'if(!$h{$F[0]}) { $h{$F[0]}=$F[1] } elsif($h{$F[0]}==$F[1]) { print }' | sort -u > ${PREFIX}.link.delete
cat ${PREFIX}.link | ${SCRIPT}/difference.pl - ${PREFIX}.link.delete -i 0 | ${SCRIPT}/difference.pl - ${PREFIX}.link.delete -i 1  > ${PREFIX}.link.clean

##################################################################################################################################################################################

#build graph
cat ${PREFIX}.link.clean | ${SCRIPT}/buildHashGraph.pl -len ${PREFIX}.len -p ${MERGEPREFIX}. -g 1>${MERGEOUT}.bed 2>${MERGEOUT}.out

#get new lengths
cat ${MERGEOUT}.bed | ${SCRIPT}/max2.pl  -i 0 -j 2 | awk '{print $1,$3}' > ${MERGEOUT}.len
cat ${PREFIX}.len | ${SCRIPT}/difference.pl - ${MERGEOUT}.bed -j 3 | ${SCRIPT}/difference.pl - ${PREFIX}.delete >> ${MERGEOUT}.len

#convert BED to FASTA
${SCRIPT}/bed2fasta.pl -bed ${MERGEOUT}.bed < ${PREFIX}.fa > ${MERGEOUT}.fa
cat ${PREFIX}.fa | ${SCRIPT}/fasta-filter.pl -n -f ${PREFIX}.delete | ${SCRIPT}/fasta-filter.pl -n -i 3 -f ${MERGEOUT}.bed  >> ${MERGEOUT}.fa
