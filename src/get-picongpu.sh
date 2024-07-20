#!/usr/bin/env bash

TGTDIR=picongpu

if [ ! -d "$TGTDIR" ]; then
	git clone https://github.com/ComputationalRadiationPhysics/picongpu.git
else
	echo "Directory $TGTDIR exists already"
fi


