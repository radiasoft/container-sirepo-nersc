#!/bin/bash
build_image_base=radiasoft/fedora
build_docker_cmd=
build_is_public=1
build_passenv='PYKERN_BRANCH SIREPO_BRANCH'
: ${PYKERN_BRANCH:=} ${SIREPO_BRANCH:=}

build_as_root() {
    _sirepo_nersc_copy_of_common_nersc
    install_repo_eval code common-nersc
}

build_as_run_user() {
    _sirepo_pip_install pykern "$PYKERN_BRANCH"
    _sirepo_pip_install sirepo "$SIREPO_BRANCH"
}

_sirepo_nersc_copy_of_common_nersc() {
    # POSIT: installers/code
    if [[ ! -e /etc/yum.repos.d/radiasoft.repo ]]; then
        install_yum_add_repo "$install_depot_server/yum/$install_os_release_id/$install_os_release_version_id/$(arch)/dev/radiasoft.repo"
    fi
    # all rpms required by mpich must be here
    declare rpms=(
        # https://bugs.python.org/issue31652
        cmake
        fftw-devel
        gcc-fortran
        glib2-devel
        hdf5-devel
        lapack-devel
        libatomic
        libffi-devel
        libtool
        llvm-libs
        hwloc
    )
    install_yum_install "${rpms[@]}"
    install_yum_install --disablerepo='*' --enablerepo=radiasoft-dev mpich mpich-devel
}

_sirepo_pip_install() {
    declare repo=$1
    declare branch=$2
    install_git_clone "$repo" "$branch"
    cd "$repo"
    install_pip_install .
    cd - &> /dev/null
    rm -rf "$repo"
}
