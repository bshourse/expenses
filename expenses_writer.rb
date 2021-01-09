# Мы хотим программу, которая позволит нам ввести в консоли трату
# (описание, категорию, дату и количество потраченных денег),
# а потом допишет её в наш файл expenses.xml.

# Алгоритм записи в xml файл
# 1. Подготавливаем данные которые нужно записать в файл
#   записываем их в массив или просто как строку
# 2. Получаем содержимое имеющегося xml файла
# 3. Находим корневой элемент и добавляем новый элемент с определенными атрибутами
# 4. Записываем новую xml структуру в файл и закрываем файл

require 'rexml/document'
require 'date'


# Начнем. Нам нужно получить имеющуюся структуру xml файла
# для этого создадим объект File и добавим проверку на наличие файла и на корректность синтаксиса xml файла
# укажем путь где лежит xml файл

current_path = File.dirname(__FILE__) + '/my_expenses.xml'

if File.exists?(current_path)
  file = File.new(current_path, "r:UTF-8")

  begin
    doc = REXML::Document.new(file)
  rescue REXML::ParseException => e
    puts "xml файл битый"
    abort e.message
  end

  file.close

else
  abort 'Xml файла не существует! Программа завершена.'
end


puts "Сколько денег вы потратили?"
expense_amount = STDIN.gets.chomp

puts "На что вы потратили деньги?"
expense_desc = STDIN.gets.chomp

puts "Введите категорию"
expense_category = STDIN.gets.chomp

puts "Когда вы потратили деньги? (Введите дату в формате DD-MM-YYYY). Пустое поле - сегодня"
date_input = STDIN.gets.chomp

#Если пользователь не ввел ничего, значит это текущая дата
# Также нам надо отформатировать дату в нужном формате

expense_date = nil

if date_input == ''
  expense_date = Date.today
else
  begin
    expense_date = Date.parse(date_input)
  rescue ArgumentError => e
    puts "Некорректно указана дата. Программа завершена"
    abort e.message
  end
end

# Добавим трату в нашу XML-структуру в переменной doc
# Для этого сначала находим корневой элемент в структуре

expenses = doc.elements.find('expenses').first

# Добавим элемент командой add_element

expense = expenses.add_element 'expense', {
    'date' => expense_date.strftime('%-d.%-m.%Y'), #осуществляем перевод в такой формат потому что в xml дата указана через точку
    'amount' => expense_amount,
    'category' => expense_category,
}

# А теперь добавим значение для тега методом text
expense.text = expense_desc

####### А теперь наконец запишем новую структуру XML файла в файл методом write #########
file = File.new(current_path, 'w:UTF-8')
doc.write(file, 2)
file.close

puts "Данные успешно записаны!"
