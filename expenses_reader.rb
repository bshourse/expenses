# Программа для учета расходов с использованием XML

# Подключаем парсер rexml и библиотеку date для эффективного использования дат\

require 'rexml/document'
require 'date'

# Запишем путь к файлу, который лежит в том же каталоге, что и программа

file_name = File.dirname(__FILE__ ) + '/my_expenses.xml'

# Если файл не найдет, завершаем программу

abort "Файл не найден. Проверьте наличия файла в каталоге с программой" unless File.exists?(file_name)

# Открываем файл и записываем дескриптор в переменную file

file = File.new(file_name)

# Считываем содержимое файла с помощью библиотеки rexml. Создаем новый объект
# класса REXML::Document, построенный из открытого XML файла.

doc = REXML::Document.new(file)

# Закрываем файл, т.к. он нам уже не нужен

file.close

# Создадим пустой ассоциативный массив amount_by_day, куда сложим все траты по
# дням в формате:
#
# {
#   день1: сумма трат в день1,
#   день2: сумма трат в день2,
#   ...
# }

amount_by_day = {}

# Выбираем из элементов документа все тэги <expense> внутри тега <expenses> и в
# цикле проходимся по ним.

doc.elements.each('expenses/expense') do |item|
  # В локальную переменную loss_sum запишем, сколько потратили
  loss_sum = item.attributes['amount'].to_i

  # В локальную переменную loss_date запишем дату траты: Date.parse создает из
  # строки объект класса Date.

  loss_date = Date.parse(item.attributes['date'])


  # Иницилизируем нулем значение хэша, соответствующее нужному дню
  # если этой даты еще не было

  amount_by_day[loss_date] ||= 0
    #Можно было записать так(записи эквивалентны):
    # amount_by_day[loss_date] = 0 if amount_by_day[loss_date] == nil

  # Наконец, учеличиваем в хэше нужное значение на сумму траты

  amount_by_day[loss_date] += loss_sum
end

# Сделаем хэш, в который соберем сумму расходов за каждый месяц

sum_by_month = {}

# В цикле по всем датам хэша amount_by_day накопим в хэше sum_by_month значения
# потраченных сумм каждого дня
amount_by_day.keys.sort.each do |key|
  # key.strftime('%B %Y') вернет одинаковую строку для всех дней одного месяца
  # поэтому можем использовать ее как уникальный для каждого месяца ключ
  # amount_by_day.keys - это будут ключи год/месяц/день

  sum_by_month[key.strftime('%B %Y')] ||= 0
  #А тут мы фактически используем ключ вида год/месяц/день для получения значения хэша в котором лежат суммы
  #и если сделать puts sum_by_month[key.strftime('%B %Y')] то мы увидим перебор сумм которые являются значениями хэша

  # puts amount_by_day[key] выведет все наши суммы трат
  # поэтому приплюсовываем к тому что было сумму следующего дня
  # и тогда у нас будет строчка с месяцем и общей суммой трат
  sum_by_month[key.strftime('%B %Y')] += amount_by_day[key]
end

# Пришло время выводить статистику на экран в цикле пройдемся по всем месяцам и
# начнем с первого(где 0 индекс массива который мы получили из хеша)

current_month = amount_by_day.keys.sort[0].strftime('%B %Y')

# Выводим заголовок для первого месяца
puts "-----[ #{current_month}, всего потрачено: " \
"#{sum_by_month[current_month]} рублей] -----"

# Цикл по всем дням

amount_by_day.keys.sort.each do |key|
  # Если текущий день принадлежит уже другому месяцу.
  if key.strftime('%B %Y') != current_month
    # То значит мы перешли на новый месяц и теперь он станет текущим
    current_month = key.strftime('%B %Y')

    # Выводим заголовок для нового текущего месяца

    puts "-----[ #{current_month}, всего потрачено: " \
    "#{sum_by_month[current_month]} рублей] -----"
  end

  # Выводим расходы за конкретный день

  puts "\t #{key.day}: #{amount_by_day[key]} рублей "

end
