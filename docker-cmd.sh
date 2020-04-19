#!/bin/bash

DINAME="localhost:5000/cinncentvnc:latest2"
DCNAME="cinncent"
HOSTNAME="cinncent"

NO_ARGS=0
E_OPTERR=65

if [ $# -eq "$NO_ARGS" ]
then
  printf "Отсутствуют аргументы. Должен быть хотя бы один аргумент.\n"
  printf "Использование: $0 {-run|-restart|-rmf|-exec|-logsf|-backup|-stop}\n"
  printf " $0 -run - создание и запуск контейнера $DCNAME\n"
  printf " $0 -restart - перезапуск контейнера $DCNAME\n"
  printf " $0 -rmf - удаление контейнера $DCNAME (docker rm -f $DCNAME)\n"
  printf " $0 -exec - подключиться к контейнеру $DCNAME (docker exec -it $DCNAME /bin/bash)\n"
  printf " $0 -logsf - вывод служебных сообщений контейнера $DCNAME (docker logs -f $DCNAME)\n"
  printf " $0 -backup - запуск резервного архивирования Gitlab-CE\n"
  exit $E_OPTERR
fi

while :; do
	case "$1" in
	-run)
	  docker run --name $DCNAME -itd \
	  -p 5901:5901 \
	  -e HOME=/tmp \
	  -v $PWD/volumes/data:/data \
	  -u 10005000 \
	  -h $HOSTNAME \
	  $DINAME
	 ;;
	-rmf)
	  docker rm -f $DCNAME
	 ;;
	-exec)
	  docker exec -it $DCNAME /bin/bash
	 ;;
	-exec0)
	  docker exec -itu 0 -w / $DCNAME /bin/bash
	 ;;
	-logsf)
	  docker logs -f $DCNAME
	 ;;
	--)
	  shift
	 ;;
	?* | -?*)
	  printf 'ПРЕДУПРЕЖДЕНИЕ: Неизвестный аргумент (проигнорировано): %s\n' "$1" >&2
	 ;;
	*)
	  break
	esac
	shift
done

exit 0
