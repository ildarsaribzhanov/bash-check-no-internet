#!/bin/bash
# http://www.cetlot.com
#
# Скрипт в бесконечном цикле пингует удалённый хост в инете с интервалом 10 сек
# при первой удачной или неудачной попытке пинга пишется соответствующее сообщение в лог
# следующая запись в лог делается только при изменении состояния связи
 
# инициализация переменной результата, по умолчанию считается, что связь уже есть
cd /var/log
result=connected
# смена текущего каталога перед записью лога
echo `date +%Y.%m.%d__%H:%M:%S`' Автоматический запуск скрипта при загрузке сервера' >> inet.log
# бесконечный цикл
while [ true ]; do
	# пинг ya.ru с последующей проверкой на ошибки
	errorscount="$(ping -c 3 ya.ru 2<&1| grep -icE 'unknown|expired|unreachable|time out')"
	# если предыдущий пинг был удачен, а текущий нет, т.е. вывод ping содержит ошибки, то
	if [ "$result" = connected -a "$errorscount" != 0 ]; then
		# запоминаем результат текущего пинга
		result=disconnected
		# и пишем в лог время разрыва соединения
		echo `date +%Y.%m.%d__%H:%M:%S`' * Cвязь отсутствует' >> inet.log
		
		# играем песню
		nohup mpg123 [/path/to/sound.mp3] &
	fi
	# если предыдущий пинг был неудачен, а текущий успешен, то
	if [ "$result" = disconnected -a "$errorscount" = 0 ]; then
		# запоминаем результат текущего пинга
		result=connected
		# и пишем в лог время установки соединения
		echo `date +%Y.%m.%d__%H:%M:%S`' Связь восстановлена' >> inet.log

		# остановим песню, если определен
		p_id=$(pidof mpg123)
		if [ $p_id ]
		then
			echo $p_id
			kill $p_id
		fi
	fi
	# каждые 10 секунд
	sleep 10
done
