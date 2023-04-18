#!/bin/bash

#source bootloader-arm64/scripts/envsetup.sh

OPTIONS="${@:-allff}"


function log() {
    local format="$1"
    shift
    printf -- "$format\n" "$@" >&2
}

function do_with_retry()
{
        local count=$1
        shift
        until "$@"; do
                ((count--))
                ((count==0)) && break
                log "Failed, Try again"
                sleep 5
        done

        if ((count==0)); then
                log "Failed, Reached Max Retry Times"
                return 1
        else
                log "Success"
        fi
}

function run() {
        if [ "$1" == "-i" ]; then
                shift
                max_try_time=1
                log "I: Running command with ignore error: %s" "$*"
        else
                max_try_time=3
                log "I: Running command: %s" "$*"
        fi
        do_with_retry ${max_try_time} "$@"
}

function build_release()
{
    if [ ! -f ".repo/manifest.xml" ]; then
        log ".repo/manifest.xml: No such file or directory"
        log "Failed"
    fi

    sdk_name=$(realpath .repo/manifest.xml  |awk -F '/' '{print $(NF) }'| awk -F '.' '{print $(1) }')
    run split -b 4000M linux_sdk_tar/${sdk_name}.sdk.tar linux_sdk_tar/${sdk_name}.sdk.split -d -a 2 --verbose

    # Create MD5
    log "I: Running command: ls ${sdk_name}.sdk.split* |sort | xargs md5sum | tee md5sum.txt"
    ls linux_sdk_tar/${sdk_name}.sdk.split* |sort | xargs md5sum | tee md5sum.txt
}

function build_tar()
{
    if [ ! -f ".repo/manifest.xml" ]; then
        log ".repo/manifest.xml: No such file or directory"
        log "Failed"
        exit 1
    fi
    sdk_name=$(realpath .repo/manifest.xml  |awk -F '/' '{print $(NF) }'| awk -F '.' '{print $(1) }')

    rm -rf
    if [ ! -d linux_sdk ];then
        mkdir -p linux_sdk_tar
    fi
    run tar cf linux_sdk_tar/${sdk_name}.sdk.tar  .repo/
}


function do_check_md5()
{
    log "Start checking MD5"
    if [ ! -f "md5sum.txt" ]; then
        log ".md5sum.txt: No such file or directory"
        log "Failed"
        exit 1
    fi

    while read line
    do
        MD5=$(echo $line | awk -F ' ' '{print $1}')
        MD5_FILE=$(echo $line | awk -F ' ' '{print $2}')


        tmp=`md5sum $MD5_FILE | awk -F ' ' '{print $1}'`

        if [ "$tmp" != "$MD5" ];then
            log "$MD5_FILE: $tmp != $MD5 check MD5 error"
            exit 1
        else
            log "$MD5_FILE: check MD5 success"
        fi
    done < md5sum.txt
}

function README()
{
README_FILE="README_ZH.txt"
cat << EOF > ${README_FILE}
 _____ _           __ _
|  ___(_)_ __ ___ / _| |_   _
| |_  | | '__/ _ \ |_| | | | |
|  _| | | | |  __/  _| | |_| |
|_|   |_|_|  \___|_| |_|\__, |
                        |___/

* 官网 www.t-firefly.com  |  www.t-chip.com.cn
* 技术支持 service@t-firefly.com
* 开源社区 https://dev.t-firefly.com/portal.php?mod=topic&topicid=11

解压和更新SDK说明：

第一次使用SDK需执行3个步骤，如果是后续想更新SDK，只需执行第3步进行网络更新即可

1. 解压SDK

chmod +x $0
$0 unpack


2. 还原工作目录

$0 sync_local


可以使用上面脚本执行或者手动执行命令，选择其中一种即可


.repo/repo/repo sync -l
.repo/repo/repo start firefly --all


3. 更新SDK

前面2个步骤只在第一次解压SDK时执行，后续更新SDK只需执行第3步骤，进行网络更新

.repo/repo/repo sync -c --no-tags

EOF

README_FILE="README_EN.txt"
cat << EOF > ${README_FILE}
 _____ _           __ _
|  ___(_)_ __ ___ / _| |_   _
| |_  | | '__/ _ \ |_| | | | |
|  _| | | | |  __/  _| | |_| |
|_|   |_|_|  \___|_| |_|\__, |
                        |___/

* Official website https://en.t-firefly.com/  |  www.t-chip.com.cn
* Technical Support service@t-firefly.com
* Forums https://bbs.t-firefly.com/forum.php?mod=forumdisplay&fid=100


Instructions for decompressing and updating the SDK:

The first time you use the SDK, you need to perform 3 steps. If you want to update the SDK later, you only need to perform step 3 to update the network.

1. Unpack the SDK

chmod +x $0
$0 unpack


2. Restore the working directory

$0 sync_local


You can use the above script to execute or manually execute the command, choose one of them


.repo/repo/repo sync -l
.repo/repo/repo start firefly --all


3. Update the SDK

The first two steps are only performed when the SDK is decompressed for the first time, and the subsequent update of the SDK only needs to perform the third step for network update

.repo/repo/repo sync -c --no-tags

EOF
}

function unpack()
{
    log "Unpack linux sdk:"
    if [ ! -f "md5sum.txt" ]; then
        log ".md5sum.txt: No such file or directory"
        log "Failed"
        exit 1
    fi

    cat md5sum.txt  |awk -F ' ' '{print $2}'| xargs cat | tar -xv

    if [ "$?" = "0" ];then
        log "Uppack linux sdk success!"
    else
        log "Uppack linux sdk fail!"
    fi


    echo -e "\n你可以查看firefly wiki，以获取SDK更多使用和开发信息:"
    echo -e "You can check the firefly wiki for more usage and development information of the SDK:"
    echo -e "EN: https://www.t-firefly.com/wiki"
    echo -e "EN: https://www.t-firefly.com/wiki"
}

function f_sync_local()
{
    if [ ! -f ".repo/repo/repo" ]; then
        log ".repo/repo/repo: No such file or directory"
        log "Failed"
        exit 1
    fi

    run .repo/repo/repo sync -l
    run .repo/repo/repo start firefly --all
}

function usage()
{
    echo -e "Usage:"
    echo -e "$0 unpack \t unpack linux SDK"
    #echo -e "$0 sync_local \t only update working tree, don't fetch"
}


for option in ${OPTIONS}; do
    case $option in
        tar) build_tar ;;
        release) build_release; README ;;
        sync_local) f_sync_local;;
        check_md5) do_check_md5;;
        unpack) do_check_md5; unpack;;
        *) usage ;;
	esac
done
