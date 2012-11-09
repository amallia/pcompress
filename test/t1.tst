#
# Simple compress and decompress
#
echo "#################################################"
echo "# Simple compress and decompress"
echo "#################################################"

for algo in lzfx lz4 zlib bzip2 lzma lzmaMt libbsc ppmd adapt adapt2
do
	../../pcompress 2>&1 | grep $algo > /dev/null
	[ $? -ne 0 ] && continue

	for level in 1 3 9 14
	do
		for tf in bin.dat share.dat inc.dat
		do
			for seg in 1m 100m
			do
				[ $level -lt 14 -a "$seg" = "100m" ] && continue

				cmd="../../pcompress -c ${algo} -l ${level} -s ${seg} ${tf}"
				echo "Running $cmd"
				eval $cmd
				if [ $? -ne 0 ]
				then
					echo "${cmd} errored."
					exit 1
				fi
				cmd="../../pcompress -d ${tf}.pz ${tf}.1"
				echo "Running $cmd"
				eval $cmd
				if [ $? -ne 0 ]
				then
					echo "${cmd} errored."
					exit 1
				fi
				diff ${tf} ${tf}.1 > /dev/null
				if [ $? -ne 0 ]
				then
					echo "${cmd}: Decompression was not correct"
					exit 1
				fi
				rm -f ${tf}.pz ${tf}.1
			done
		done
	done
done

echo "#################################################"
echo ""

