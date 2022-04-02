#!/bin/bash
# https://stackoverflow.com/questions/46173298/how-to-sort-or-order-results-docker-ps-format
# https://i-rrv.ru/wiki/index.php/Awk_-_рецепты
# http://dbserv.pnpi.spb.ru/~shevel/Book/node72.html
# https://askubuntu.com/questions/1098248/how-can-i-install-the-util-linux-version-of-the-column-command-in-18-04
#echo $1

# $ cd ~/Downloads/
# $ wget https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v2.35/util-linux-2.35-rc1.tar.gz
# $ tar -xvf util-linux-2.35-rc1.tar.gz
# $ cd util-linux-2.35-rc1/
# $ ./configure
# $ make column
# $ cp .libs/column ~/bin/
# $ cd ..
# $ rm -rf util-linux-2.35-rc1*
# $ column --version
# column from util-linux 2.35-rc1
# https://cheatography.com/mynocksonmyfalcon/cheat-sheets/micro-text-editor/
# проверена работа в CentOS, Linux Mint на gawk 4.1.4 и column from util-linux 2.35-rc1

# в Debian строку
# | column -t -s '==' -o ' ' \
# заменить на
# | column -t -s '==' \,
# расст м/у колонками в этом случае состами 2 таба, можно уменьшить управляя substr
# или установить util-linux

function dps () {
		# по умолчанию сортировка произв-ся по 2-му столбцу
		# dpsc 1 - сортировка по имени
		if [[ $1 ]]; then
			order=-k$1
		else
			order=-mk2
		fi;
        command docker ps --format \
        "table {{.Names}}==>>{{.Status}}==>>{{.Networks}}==>>{{.Ports}}" \
        | (read -r; printf "%s\n" "$REPLY"; sort $order ) \
            | /bin/column -t -s '==' -o ' ' \
			| gawk 'BEGIN {FS=">>"} {if (NR%2==0) {printf "\033[0;48;5;233m"}}
 			{if (NR==1) printf "%1$s %2$s %3$s %4$s\n",
 			$1, $2, $3, $4;
 			else printf "\033[91m%1s \033[38;5;45m%2s \033[38;5;78m%3s \033[93m%4s \033[0m\n",
 			$1, $2, $3, $4;}'
}

function dps2 () {
         command docker ps $@ --format \
         "table {{.Names}}==>>{{.CreatedAt}}==>>{{.Status}}==>>{{.Networks}}==>>{{.Ports}}" \
             | /bin/column -t -s '==' -o ' ' \
 			| awk 'BEGIN {FS=">>"} {if (NR%2==0) {printf "\033[0;48;5;233m"}}
 			{if (NR==1) printf "%1$s%2$s%3$s%4$s%5$s\n",
 			$1, substr($2, 0, 18), $3, $4, $5;
 			else printf "\033[32m%s\033[96m%s\033[95m  %s\033[94m%s\033[93m%-23s \033[0m\n",
 			$1, substr($2, 0, 16), $3, $4, substr($5, 0, match($5, ",")-1);}'
 }

dps $@
