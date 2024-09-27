#!/bin/bash
###############################################################
# This shell used to make ML tree using ClustalW and FastTree #
# from Fasta protein file. Written by Zengyan Xie.            #
###############################################################

if [ $# != 1 ]
then
        echo "Usage: $0 ProteinFile(Fasta format)"
        exit 1
fi

infile=$1
basename=`echo $infile |cut -d'_' -f1`

# alignment
echo "Alignning ......"
clustalw2 <<eof >/dev/null
1
$infile
2
9
4

1



x

x
eof

echo "Done. Alignment is finished ......"
