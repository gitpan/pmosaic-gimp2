#!/bin/bash
FILE=${1:-testcard.png}
BASE=${FILE/%.*}
INDEX=${2:-$(pwd)/pmosaic-index-munged}
COUNT=${3:-10}
shift 3
SPUDS=${*:-15 30 100 255 1}
mkdir -p output
for t in $SPUDS ; do
	echo "File: $FILE,  tolerance: $t"
	perl -MBenchmark -e "timethis($COUNT, sub { system('../pmosaic \
		-imgfile img/${FILE}                                         \
		-display 0                                                   \
		-index $INDEX                                                \
		-tolerance $t                                                \
		-statistics 1                                                \
		>& /dev/null                                                 \
	') } )" >& ${BASE}-tolerance$t.benchmark

	if [ $? == 0 ]; then
		mv img/PM__${BASE}.xcf output/PM__${BASE}-tolerance$t.xcf
		mv img/${FILE}.statistics output/${BASE}-tolerance$t.statistics
	fi
done
