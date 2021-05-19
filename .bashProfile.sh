alias c=clearAll
alias bashReset="source ~/.zshrc"
alias bashEdit="vim ~/.bashProfile.sh && bashReset"
alias locationFinder="pwd"
alias wrap="eval tput smam"
alias nowrap="eval tput rmam"
alias theTruth="say There is a reason why the curse of sin is broken, There is a reason why the darkness runs from light ,There is a reason why we stand here now forgiven, Momo is the true Lord"

export GOPATH=~/go/
export GOBIN=$GOPATH/bin
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin

ZSH_THEME=wedisagree
RED='\033[0;33m'
LIGHTRED='\033[1;31m'
LIGHTBLUE='\033[1;34m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

function findBigFiles(){
  git rev-list --objects --all \
    | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' \
    | awk '/^blob/ {print substr($0,6)}' \
    | sort --numeric-sort --key=2 \
    | gcut --complement --characters=13-40 \
    | gnumfmt --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest
  }
#-------------------------------------------- Kafka
function kafkaInstall(){
  eval brew install kafka
  eval brew install zookeeper
}
function kafkaUp(){
  eval zookeeper-server-start /usr/local/etc/kafka/zookeeper.properties &
  eval kafka-server-start /usr/local/etc/kafka/server.properties &
}
function kafkaTopicUp(){
  if [ "$1" != "" ]
  then
    eval kafka-topics --create --zookeeper localhost:4492 --replication-factor 1 --partitions 1 --topic $1
  else
    echo "Choose a Topic"
  fi
}
function kafkaS(){
  if [ "$1" != "" ]
  then
    eval kafka-console-producer --broker-list ecpkafka-dev.aexp.com:4492 --topic $1  
  else
    echo "Choose a Topic"
  fi
}
function kafkaR(){
  if [ "$1" != "" ]
  then
    if [ "$2" = "" ]
    then
      eval kafka-console-consumer --bootstrap-server localhost:9092 --topic $1 --from-beginning
    else
      eval kafka-console-consumer --bootstrap-server localhost:9092 --topic $1
    fi
  else
    echo "Choose a Topic"
  fi
}
function ff(){
  eval grep --exclude-dir=vendor -r '$1' .
}
function clearAll(){
  eval clear && printf "\e[3J"
}
function m(){
  if [ "$1" != "" ]
  then
    eval cd "$1"
  fi
  eval ls -la
  echo ${YELLOW}
  locationFinder
  echo ${NC}
}
function goWork(){
  eval cd $GOPATH/src
  locationFinder
}
function goTest(){
  echo " ${RED}goImports  ${NC}"
  eval goimports -l ./ | grep -v vendor
  echo " ${RED}goFmt  ${NC}"
  eval gofmt -s -l . | grep -v vendor | wc -l | grep -q 0
  echo " ${RED}goLint  ${NC}"
  eval golint ./... | grep -v vendor
  echo " ${RED}goVet  ${NC}"
  eval go vet -c=2 ./...
  echo " ${RED}goSec  ${NC}"
  eval gosec ./...
  echo " ${RED}goReportCard  ${NC}"  
  eval goreportcard-cli -v | grep -v vendor  
}
function dockerReset(){
  runAfter=false
  fileRun=false
  webRun=false
  removeAll=false
  webRunP=""
  fileRunP=""
  defaultImgName="dockerimage"$(eval date +%H%M%S)
  imgName=$defaultImgName
  for var in "$@"
  do
    in=$(echo $var | tr "=" "\n")
    p=${in[1]}${in[2]}
    in[1]=""
    in[1]=""
    in[1]=""
    val=${in[*]}
    if [ $p = "-r" ] || [ $p = "-R" ]
    then
      ##echo "${YELLOW}Start after Build${NC}"
      runAfter=true
    elif [ $p = "-f" ] || [ $p = "-F" ]
    then
      ##echo "${YELLOW}Create from File${NC}"
      fileRun=true
      fileRunP=$val
    elif [ $p = "-w" ] || [ $p = "-W" ]
    then
      ##echo "${YELLOW}Create from Repo${NC}"
      webRun=true
      webRunP=$val
    elif [ $p = "-q" ] || [ $p = "-Q" ]
    then
      ##echo "${YELLOW}Reset${NC}"
      removeAll=true
    elif [ $p = "-n" ] || [ $p = "-N" ]
    then
      ##echo "${YELLOW}Name on the Container${NC}"
      imgName=$val
    fi
  done
  echo "${RED}Stop All the Containers${NC}"
  eval docker stop $(docker ps -aq)
  echo "${RED}Remove All the Containers${NC}"
  eval docker rm $(docker ps -aq)
  if [[ $fileRun = true ]] || [[ $webRun = true ]] || [[ $removeAll = true ]] || [[ $runAfter = true ]] || [[ $imgName != $defaultImgName ]]
  then
    if [[ $removeAll = true ]]
    then
      echo "${RED}Remove All the Images${NC}"
      eval docker rmi $(docker images -q) -f
    else
      eval docker rmi $imgName -f
    fi
    if [[ $fileRun = true ]]
    then
      eval goWork
      eval cd $fileRunP
      echo "${RED}"
      eval locationFinder
      echo "${NC}"
      echo "${RED}Create a Image${NC}"
      eval docker build -t "$imgName" .
      echo "${RED} The Image Name =${LIGHTRED} $imgName ${NC}"
    elif [[ $webRun = true ]]
    then
      echo "${RED}Create a Image from Repo${NC}"
      echo "${RED} The Image Name =${LIGHTRED} $imgName ${NC}"
      eval docker build -t $imgName $webRunP
    fi
    if [[ $runAfter = true ]]
    then
      echo "${RED}Run the Image${NC}"
      eval docker run --name "$imgName" -d -p 20000-20100:20000-20100 "$imgName" &
      echo "checking the log"
      sleep 2
      eval docker logs "$imgName" -f
    fi
  fi
}
function openRepo(){
    if [[ $1 != "" ]];then
    eval $1
  fi
  MYVAR=$(git remote -v)
  VARS=${MYVAR%\(*}
  VARS=${VARS%\(*}
  VARS=${VARS##*:}
  VARS="https:"${VARS}
  eval open "$VARS" 
}
function GoPkgInstall(){
  eval go get github.com/gojp/goreportcard/cmd/goreportcard-cli
  echo "goreportcard-cli Installed"
  eval go get -u github.com/google/pprof
  echo "pprof Installed"
  eval go get -u github.com/cweill/gotests/...
  echo "gotests Installed"
  eval go get -u golang.org/x/lint/golint
  echo "golint Installed"
  eval go get -u github.com/gordonklaus/ineffassign
  echo "ineffassign Installed"
  eval go get -u github.com/alecthomas/gometalinter
  echo "gometalinter Installed"
  eval go get -u github.com/client9/misspell/cmd/misspell
  echo "misspell Installed"
  eval go get github.com/fzipp/gocyclo
  echo "gocyclo Installed"
}
function rmswp(){
  count=$(find ./ -type f -name "*.swp" | wc -l)
  if (( $count != 0 )); then
    eval 'find ./ -type f -name "*.swp"'
    echo "----------------"
    echo "Are You Sure ? y/n"
    read a
    if [[ $a = y ]] || [[ $a = Y ]]; then
      eval 'find ./ -type f -name "*.swp" -delete'
      echo "Done"
    else
      echo "Canceled"
    fi
  fi
}


