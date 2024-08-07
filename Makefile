
PWD = $(shell pwd)

COMMIT_HASH = $(shell git log -1 --format='%h')
COMMIT_TS = $(shell git log -1 --format='%at')


#
# Checks the log for underfull/overfull warnings.
# For narrow displays, only check overfull.
#
check-lines:
ifdef NARROW
	! grep -i 'Overfull' ${JOB}.log
else
	! grep -i 'in paragraph at lines' ${JOB}.log
endif


draft: \
	pdf-build1


# build: pdf-build1 make-index check-refs check-lines
build: clear-files pdf-build1 make-index pdf-build2 pdf-build3 check-refs check-lines


## Build an index file with Clojure.
make-index:
	echo 'make-index'
	cd makeindex && \
	/lein run ${PWD}/${JOB}.idx ${PWD}/${JOB}.ind


# Drop unused files.
clear-files:
	rm -f *.aux
	rm -f *.ilg
	rm -f *.idx
	rm -f *.ind
	rm -f *.log
	rm -f ${JOB}.pdf
	rm -f *.toc
	rm -f *.pyg
	rm -rf _minted-*
	rm -rf svg-inkscape
	rm -f *.out

clear-pdf:
	rm -f *.pdf

inc-builds:
	expr `cat BUILDS` + 1 > BUILDS

#
# A common LaTeX build command with three aliases
#
pdf-build1 pdf-build2 pdf-build3: inc-builds
	COMMIT_HASH=${COMMIT_HASH} \
	COMMIT_TS=${COMMIT_TS} \
	envsubst < main.tex | pdflatex -shell-escape -halt-on-error -jobname=${JOB}


#
# Check if there are any missing references inside the doc.
#
check-refs:
	! grep -i 'LaTeX Warning: Reference' ${JOB}.log


IMG = clj-book2
IMG_SYS = ${IMG}:ubuntu
IMG_RUN = ${IMG}:build


docker-build-ubuntu:
	docker build --no-cache -t ${IMG_SYS} -f Dockerfile.ubuntu .


docker-build-image:
	docker build --no-cache -t ${IMG_RUN} .


docker-build-images: docker-build-ubuntu docker-build-image


DOCKER_RUN = \
	docker run -it --rm \
	-v $(CURDIR)/:/book \
	-w /book \
	-e COMMIT_HASH=${COMMIT_HASH} \
	-e COMMIT_TS=${COMMIT_TS} \
	--env-file=ENV

DOCKER_DRAFT = ${DOCKER_RUN} --env-file=ENV_DRAFT

MAKE_BUILD = ${IMG_RUN} make build
MAKE_DRAFT = ${IMG_RUN} make draft


#
# Desktop
#

docker-build-desktop:
	${DOCKER_RUN} --env-file=ENV_DESKTOP ${MAKE_BUILD}


#
# Print
#

docker-build-print:
	${DOCKER_RUN} --env-file=ENV_PRINT ${MAKE_BUILD}


docker-build-print-draft:
	${DOCKER_DRAFT} --env-file=ENV_PRINT ${MAKE_DRAFT}


#
# DMK
#

docker-build-dmk:
	${DOCKER_RUN} --env-file=ENV_DMK ${MAKE_BUILD}

docker-build-dmk-draft:
	${DOCKER_DRAFT} --env-file=ENV_DMK ${MAKE_DRAFT}


#
# Kindle
#

docker-build-kindle:
	${DOCKER_RUN} --env-file=ENV_KINDLE ${MAKE_BUILD}

docker-build-kindle-draft:
	${DOCKER_DRAFT} --env-file=ENV_KINDLE ${MAKE_DRAFT}


#
# Phone
#

docker-build-phone:
	${DOCKER_RUN} --env-file=ENV_PHONE ${MAKE_BUILD}

docker-build-phone-draft:
	${DOCKER_DRAFT} --env-file=ENV_PHONE ${MAKE_DRAFT}


#
# Tablet
#

docker-build-tablet:
	${DOCKER_RUN} --env-file=ENV_TABLET ${MAKE_BUILD}

docker-build-tablet-draft:
	${DOCKER_DRAFT} --env-file=ENV_TABLET ${MAKE_DRAFT}


#
# Digital bundle (for selling)
#

docker-build-digital: \
	docker-build-print \
	zip-digital


#
# ALL bundle
#

docker-build-all: \
	docker-build-digital \
	docker-build-dmk


#
# Local debug
#

show-stats:
	find . -name '*.tex' | xargs wc -ml


check-urls:
	./check-urls.sh


lines-kindle:
	! grep -i 'Overfull' clojure_kindle.log


lines-phone:
	! grep -i 'Overfull' clojure_phone.log


#
# Zip
#

ZIPDIR = ./clojure-in-production-2

zip-digital:
	mkdir ${ZIPDIR}
	cp clojure_print.pdf   ${ZIPDIR}
	rm -f ${ZIPDIR}.zip
	zip -r ${ZIPDIR}.zip ${ZIPDIR}
	rm -rf ${ZIPDIR}
