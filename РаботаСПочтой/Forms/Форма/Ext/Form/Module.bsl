﻿
&НаКлиенте
Процедура ПолучитьПочту(Команда)
	
	//Получить почтовый профиль
	Профиль = ПолучитьПрофиль();
	
	Сообщ = Новый СообщениеПользователю();
	
	Почта = Новый ИнтернетПочта;
	
	Попытка
		
		Если Объект.ИспользоватьIMAP Тогда
			Почта.Подключиться(Профиль, ПротоколИнтернетПочты.IMAP);
		Иначе
			Почта.Подключиться(Профиль, ПротоколИнтернетПочты.POP3);
		КонецЕсли;
		
	Исключение
		
		//Вывести сообщение об ошибке
		Сообщ.Текст = "Ошибка при подключении или приеме " + ОписаниеОшибки();
		Сообщ.Сообщить();
		Возврат;
		
	КонецПопытки;
	
	//Получить заголовки сообщений с отбором из почтового ящика
	ПараметрыОтбораIMAP = Новый Структура;
	ПараметрыОтбораIMAP.Вставить("Прочитанные", Ложь);
	ЗаголовкиСообщений = Почта.ПолучитьЗаголовки(ПараметрыОтбораIMAP);
	
	КоличествоСообщений = ЗаголовкиСообщений.Количество();
	Если КоличествоСообщений = 0 Тогда
		
		Сообщ.Текст = "Сообщений в почтовом ящике нет.";
		Сообщ.Сообщить();
		Почта.Отключиться();
		Возврат;
		
	КонецЕсли;
	
	//Создать соответствия флагов сообщений
	ФлагиСообщенийIMAP = Новый Соответствие;
	
	//Получить сообщения полностью
	МассивСообщений = Почта.Выбрать(Ложь, ЗаголовкиСообщений);
	Для Индекс = 0 По КоличествоСообщений -1 Цикл
		
		ФлагСообщения = Новый ФлагиИнтернетПочтовогоСообщения();
		ФлагСообщения.Удаленное = Истина;
		ФлагиСообщенийIMAP.Вставить(МассивСообщений[Индекс].Индентификатор[0], ФлагСообщения);
		
		Сообщ.Текст = "Принято сообщение " + МассивСообщений[Индекс].Тема;
		Сообщ.Сообщить();
		
		Если Индекс = КоличествоСообщений - 1 Тогда
			Для каждого Элемент Из МассивСообщений[Индекс].Тексты Цикл
				Если Элемент.ТипТекста - ТипТекстаПочтовогоСообщения.HTML Тогда
					
					//Отобразить тело сообщения в HTML документе
					ТекстHTML = Элемент.Текст;
					Если Найти(ТекстHTML, "<HTML>") = 0 Тогда	
						ТекстHTML = "<HTML><BODY>" + ТекстHTML + "</BODY></HTML>";	
					КонецЕсли;
					
					Вложения = Новый Массив;
					//Обработать вложения, чтобы правильно сформировать HTML
					Для Каждого Вложение Из МассивСообщений[Индекс].Вложения Цикл
						
						ИД = "cid:" + Вложение.Идентификатор;
						Если Найти(ТекстHTML, ИД) <> 0 Тогда
							Вложения.Добавить(Вложение);	
						КонецЕсли;
					КонецЦикла;	
				КонецЕсли;
			КонецЦикла;
			
			Индекс = 0;
			Для Каждого Вложение Из Вложения Цикл
				//Записать файл картинки во временный файл
				ФайлОбмена = Вложение.Данные;
				ИмяФайла = //Путь для вложений;
				ФайлОбмена.Записать(ИмяФайла);
				
				//Отобразить картинки в html 
				ИД = """cid:" + Вложение.Идентификатор + """";
				ТекстHTML = СтрЗаменить(ТекстHTML, ИД, """" + ИмяФайла + """");
				Индекс = Индекс + 1;
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;
	Почта.УстановитьФлагиСообщений(ФлагиСообщенийIMAP);
	Почта.Отключиться();
КонецПроцедуры

&НаКлиенте
Функция ПолучитьПрофиль()
	
	//Создать почтовый профиль
	Профиль = Новый ИнтернетПочтовыйПрофиль;
	
	Профиль.АдресСервераSMTP = Объект.SMTPСервер;
	Профиль.ПользовательSMTP = Объект.Пользователь;
	Профиль.ПарольSMTP = Объект.Пароль;
	Профиль.ТолькоЗащищеннаяАутентификацияSMTP = Истина;
	
	Профиль.АдресСервераPOP3 = Объект.POP3Сервер;
	Профиль.Пользователь = Объект.Пользователь;
	Профиль.Пароль = Объект.Пароль;
	
	Профиль.АдресСервераIMAP = Объект.IMAPСервер;
	Профиль.ПользовательIMAP = Объект.Пользователь;
	Профиль.ПарольIMAP = Объект.Пароль;
	
	Возврат Профиль;
	
КонецФункции

&НаКлиенте
Процедура ЗаполнитьПоля(Команда)
	//Тут был код для быстрого заполнения полей
КонецПроцедуры

&НаКлиенте
Процедура ОтправитьПочту(Команда)
	Перем HTML, Картинки;
	
	//Получить почтовый профиль
	Профиль = ПолучитьПрофиль();
	
	//Сформировать сообщение, содержащее форматированный документ
	Сообщение = Новый ИнтернетПочтовоеСообщение;
	Сообщение.Тема = "Форматированный документ";
	Сообщение.Отправитель = Объект.АдресОтправителя;
	
	Сообщение.Получатели.Добавить(Объект.АдресПолучателя);
	
	//Создать вложения с картинками
	Объект.Содержимое.ПолучитьHTML(HTML, Картинки);
	Для Каждого Картинка Из Картинки Цикл
		
		Вложение = Сообщение.Вложения.Добавить(Картинка.Значение.ПолучитьДвоичныеДанные());
		Вложение.Идентификатор = Картинка.Ключ;
		Вложение.Имя = Картинка.Ключ;
		HTML = СтрЗаменить(HTML, Картинка.Ключ, "cid:" + Вложение.Идентификатор);
		
	КонецЦикла;
	
	ТекстСообщения = Сообщение.Тексты.Добавить(HTML, ТипТекстаПочтовогоСообщения.HTML);
	
	Почта = Новый ИнтернетПочта;
	
	Сообщ = Новый СообщениеПользователю();
	
	Попытка
		
		Почта.Подключиться(Профиль);
		//Отправить сообщение с форматированным текстом и картинками
		Почта.Послать(Сообщение);
		
	Исключение
		
		//Вывести сообщение об ошибке
		Сообщ.Текст = "Ошибка при отправке файла: " + Объект.ФайлВложения;
		Сообщ.Сообщить();
		Сообщ.Текст = ОписаниеОшибки();
		Сообщ.Сообщить();
		Возврат;
		
	КонецПопытки;
	
	Сообщ.Текст = "Сообщение отправлено.";
	Сообщ.Сообщить();
	
	Почта.Отключиться();
КонецПроцедуры
