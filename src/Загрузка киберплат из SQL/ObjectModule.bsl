﻿
Процедура  АвтоматическаяЗагрузкаДанныхПС() Экспорт
	
	Таблица = ДанныеИЗSQL_МТСб(ДатаС, ДатаПо);
	Если ТипЗнч(Таблица) = Тип("ТаблицаЗначений") Тогда
		Если Таблица.Количество() > 0 Тогда
			
			
			Запрос = Новый Запрос;
			Запрос.Текст = 
			"ВЫБРАТЬ
			|	ПлатежиВМТСБ.Ссылка,
			|   ПлатежиВМТСБ.Транзакцияпровайдера
			|ИЗ
			|	Документ.ПлатежиВМТСБ КАК ПлатежиВМТСБ
			|ГДЕ
			|	ПлатежиВМТСБ.Дата МЕЖДУ &Дата1 И &Дата2";
			Запрос.УстановитьПараметр("Дата1", НачалоДня(ТекущаяДата()-60*60*24));
			Запрос.УстановитьПараметр("Дата2", КонецДня(ТекущаяДата()-60*60*24));
			//Запрос.УстановитьПараметр("Транзакция", Строка.НомерТранзакции);
			Рез = Запрос.Выполнить().Выгрузить();
			
			
			Попытка
				Для каждого СтрокаТаблицы ИЗ Таблица Цикл
					
					НайденныйДокумент = Рез.Найти(СтрокаТаблицы.Транзакцияпровайдера);
					Если НайденныйДокумент <> Неопределено тогда						
						продолжить;
					КонецЕсли;											
					СохранитьПлатежиВДокументы_МТСб(СтрокаТаблицы);
				КонецЦикла;
			Исключение
			КонецПопытки;
		КонецЕсли;			
	КонецЕсли;	
	
	
	Таблица = ДанныеИЗSQL_Киберплат(ДатаС, ДатаПо);
	Если ТипЗнч(Таблица) = Тип("ТаблицаЗначений") Тогда
		Попытка
			Для каждого СтрокаТаблицы ИЗ Таблица Цикл
				СохранитьПлатежиВДокументы_Киберплат(СтрокаТаблицы);
			КонецЦикла;
		Исключение
		КонецПопытки;		
	КонецЕсли;

	
	
	Попытка
		ПровестиДокиПлатежи(ДатаС, ДатаПо);
	Исключение
	КонецПопытки;
	
	Попытка
		ПровестиДокиПлатежиКибер(ДатаС, ДатаПо);
	Исключение
	КонецПопытки;
КонецПроцедуры	



Процедура СохранитьПлатежиВДокументы_МТСб(Таблица) Экспорт
	
	Платеж = Документы.ПлатежиВМТСБ.СоздатьДокумент();
	Платеж.Заполнить(Таблица); 
	Попытка
		Платеж.Записать();
		Платеж.Записать(РежимЗаписиДокумента.Проведение);
	Исключение
	КонецПопытки;
	
КонецПроцедуры	

Процедура  СохранитьПлатежиВДокументы_Киберплат(Таблица) Экспорт
	Платеж = Документы.ПлатежиВКиберплате.СоздатьДокумент();
	Платеж.Заполнить(Таблица); 
	Попытка
		Платеж.Записать();
		//Платеж.Записать(РежимЗаписиДокумента.Проведение);
	Исключение
	КонецПопытки;
	
КонецПроцедуры	


Функция  ДанныеИЗSQL_МТСб(ДатаС, ДатаПо) Экспорт
	
	СтрокаСоединения = ("Provider=SQLOLEDB;Driver={SQL Server};Deleted=No;Data Source=0001RTCSQL01\JEEVES;UID=sverka_1c;PWD=Rk%xgLbjgj;Database=DB0001RTCRapida");
	Подключение = Новый ComObject("ADODB.Connection");
	Попытка
		Подключение.Open(СтрокаСоединения); 
		#Если клиент тогда
		Состояние ("Подключение к серверу SQL...");
		#КонецЕсли
	Исключение
		#Если клиент тогда
		Сообщить(ОписаниеОшибки());
		#КонецЕсли
		Возврат Ложь;
	КонецПопытки;	

	ТекстЗапроса = "SELECT DISTINCT [ID платежа]
	|	,[Время сервера]
	|	,[Статус]
	|	,[Субстатус]
	|	,[Номер]
	|	,[Номер чека]
	|	,[№ операции на терминале]
	|	,[Сервис]
	|	,[Точка]
	|	,[Точка ID]
	|	,[Принятая сумма]
	|	,[Сумма зачисленная]
	|	,[Комиссия с клиента]
	|	,[Сумма наличности]
	|	,[Исправленная операция]
	|	,[Транзакция провайдера]
	|	,[Тип платежа]
	|	,[ReportNumber]
	|	,[Comment]
	|FROM [DB0001RTCRapida].[dbo].[ПлатежиОтМтсбанка]
	|where [Время сервера] between '" + Формат(ДатаС,"ДФ=ггггММдд")+" "+ Формат(ДатаС,"ДФ= ЧЧ:мм:сс")+ ".000' and '" + Формат(ДатаПо,"ДФ=ггггММдд")+" "+ Формат(ДатаПо,"ДФ= ЧЧ:мм:сс") +".000'" + " AND [Статус] IN ('Успех') ";
	СоединениеSQL = Новый COMObject("ADODB.Command");
	СоединениеSQL.ActiveConnection = Подключение;
	//СоединениеSQL.NamedParameters = True;
	СоединениеSQL.CommandText = ТекстЗапроса;
	СоединениеSQL.CommandType = "text";
	СоединениеSQL.CommandTimeOut = 200;
	ЗаписиSQL = Новый ComObject("ADODB.RecordSet");
	
	Попытка
		ЗаписиSQL = СоединениеSQL.Execute();
		#Если клиент тогда
		Состояние("выполнение запроса");
		#КонецЕсли
	Исключение
		#Если клиент тогда
		Сообщить(ОписаниеОшибки());
		#КонецЕсли
		Подключение.Close();
		#Если клиент тогда
		Сообщить("Подключение закрыто из-за ошибки");
		#КонецЕсли
		Возврат Ложь;
	КонецПопытки;
	
	Таблица = Новый ТаблицаЗначений;
	#Если клиент тогда
	Состояние ("Заполнение временной таблицы...");
	#КонецЕсли
	Для НомерСтолбца = 0 По ЗаписиSQL.Fields.Count-1 Цикл //Создание и добавление колонок во временную таблицу
		ИмяСтолбца =ЗаписиSQL.Fields.Item(НомерСтолбца).Name;
		Таблица.Колонки.Добавить(стрЗаменить(стрЗаменить(ИмяСтолбца," ",""), "№","Номер"));
	КонецЦикла;
	
	Пока ЗаписиSQL.EOF = 0 Цикл // Заполнение созданной таблицы
		НоваяСтрока =  Таблица.Добавить();
		Для НомерСтолбца = 0 По ЗаписиSQL.Fields.Count-1 Цикл
			НоваяСтрока.Установить(НомерСтолбца,ЗаписиSQL.Fields(НомерСтолбца).Value);
			//Сообщить ("Test " + ЗаписиSQL.Fields(НомерСтолбца).Value);
			#Если клиент тогда
			ОбработкаПрерыванияПользователя();
			#КонецЕсли
		КонецЦикла;
		ЗаписиSQL.MoveNext();
	КонецЦикла;
	Подключение.Close();
	
	Возврат Таблица;
	
	
	
	
	
КонецФункции

Функция  ДанныеИЗSQL_Киберплат(ДатаС, ДатаПо) Экспорт
	
	СтрокаСоединения = ("Provider=SQLOLEDB;Driver={SQL Server};Deleted=No;Data Source=0001RTCSQL01\JEEVES;UID=sverka_1c;PWD=Rk%xgLbjgj;Database=DB0001RTCRapida");
	Подключение = Новый ComObject("ADODB.Connection");
	Попытка
		Подключение.Open(СтрокаСоединения); 
		#Если клиент тогда
		Состояние ("Подключение к серверу SQL...");
		#КонецЕсли
	Исключение
		#Если клиент тогда
		Сообщить(ОписаниеОшибки());
		#КонецЕсли
		Возврат Ложь;
	КонецПопытки;	

	ТекстЗапроса = "SELECT DISTINCT [Номер]
	|	,[ДатаВремя]
	|	,[ТочкаПриема]
	|	,[Счет]
	|	,[Телефон]
	|	,[Сумма]
	|	,[Кодсессии]
	|	,[Комментарий]
	|	,[Тип]
	|	,[СуммаКомиссия]
	|FROM [DB0001RTCRapida].[dbo].[ПлатежиОтКиберплат]
	|where [ДатаВремя] between '" + Формат(ДатаС,"ДФ=ггггММдд")+" "+ Формат(ДатаС,"ДФ= ЧЧ:мм:сс")+ ".000' and '" + Формат(ДатаПо,"ДФ=ггггММдд")+" "+ Формат(ДатаПо,"ДФ= ЧЧ:мм:сс") +".000'" ;
	СоединениеSQL = Новый COMObject("ADODB.Command");
	СоединениеSQL.ActiveConnection = Подключение;
	//СоединениеSQL.NamedParameters = True;
	СоединениеSQL.CommandText = ТекстЗапроса;
	СоединениеSQL.CommandType = "text";
	СоединениеSQL.CommandTimeOut = 200;
	ЗаписиSQL = Новый ComObject("ADODB.RecordSet");
	
	Попытка
		ЗаписиSQL = СоединениеSQL.Execute();
		#Если клиент тогда
		Состояние("выполнение запроса");
		#КонецЕсли
	Исключение
		#Если клиент тогда
		Сообщить(ОписаниеОшибки());
		#КонецЕсли
		Подключение.Close();
		#Если клиент тогда
		Сообщить("Подключение закрыто из-за ошибки");
		#КонецЕсли
		Возврат Ложь;
	КонецПопытки;
	
	Таблица = Новый ТаблицаЗначений;
	#Если клиент тогда
	Состояние ("Заполнение временной таблицы...");
	#КонецЕсли
	Для НомерСтолбца = 0 По ЗаписиSQL.Fields.Count-1 Цикл //Создание и добавление колонок во временную таблицу
		ИмяСтолбца =ЗаписиSQL.Fields.Item(НомерСтолбца).Name;
		Таблица.Колонки.Добавить(стрЗаменить(ИмяСтолбца," ",""));
	КонецЦикла;
	
	Пока ЗаписиSQL.EOF = 0 Цикл // Заполнение созданной таблицы
		НоваяСтрока =  Таблица.Добавить();
		Для НомерСтолбца = 0 По ЗаписиSQL.Fields.Count-1 Цикл
			НоваяСтрока.Установить(НомерСтолбца,ЗаписиSQL.Fields(НомерСтолбца).Value);
			//Сообщить ("Test " + ЗаписиSQL.Fields(НомерСтолбца).Value);
			#Если клиент тогда
			ОбработкаПрерыванияПользователя();
			#КонецЕсли
		КонецЦикла;
		ЗаписиSQL.MoveNext();
	КонецЦикла;
	Подключение.Close();
	
	Возврат Таблица;
	
	
	
	
	
КонецФункции


Процедура ПровестиДокиПлатежи(ДатаН, ДатаК) Экспорт 
	ЗапросПОДокам = новый Запрос();
	ЗапросПОДокам.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ
	                      |	ПриемПлатежей.Ссылка
	                      |ПОМЕСТИТЬ Платежи
	                      |ИЗ
	                      |	Документ.ПриемПлатежей КАК ПриемПлатежей
	                      |ГДЕ
	                      |	ПриемПлатежей.Дата МЕЖДУ &ДатаН И &ДатаК
	                      |;
	                      |
	                      |////////////////////////////////////////////////////////////////////////////////
	                      |ВЫБРАТЬ РАЗЛИЧНЫЕ
	                      |	ВозвратПлатежей.Ссылка
	                      |ПОМЕСТИТЬ Взв
	                      |ИЗ
	                      |	Документ.ВозвратПлатежей КАК ВозвратПлатежей
	                      |ГДЕ
	                      |	ВозвратПлатежей.Дата МЕЖДУ &ДатаН И &ДатаК
	                      |;
	                      |
	                      |////////////////////////////////////////////////////////////////////////////////
	                      |ВЫБРАТЬ
	                      |	Взв.Ссылка КАК Возврат,
	                      |	Платежи.Ссылка КАК Платеж
	                      |ИЗ
	                      |	Платежи КАК Платежи,
	                      |	Взв КАК Взв";
						  //|
						  //|ОБЪЕДИНИТЬ ВСЕ
						  //|
						  //|ВЫБРАТЬ
						  //|	ПриемПлатежейЗК.Ссылка
						  //|ИЗ
						  //|	Документ.ПриемПлатежейЗК КАК ПриемПлатежейЗК
						  //|ГДЕ
						  //|	ПриемПлатежейЗК.Проведен = ""Ложь""
						  //|	И ПриемПлатежейЗК.Дата МЕЖДУ &ДатаН И &ДатаК
						  //|
						  //|ОБЪЕДИНИТЬ ВСЕ
						  //|
						  //|ВЫБРАТЬ
						  //|	КредитыЗолотаяКоронаЛП.Ссылка
						  //|ИЗ
						  //|	Документ.КредитыЗолотаяКоронаЛП КАК КредитыЗолотаяКоронаЛП
						  //|ГДЕ
						  //|	КредитыЗолотаяКоронаЛП.Проведен = Ложь
						  //|	И КредитыЗолотаяКоронаЛП.Дата МЕЖДУ &ДатаН И &ДатаК";
						  //|
						  //|ОБЪЕДИНИТЬ ВСЕ
						  //|
						  //|ВЫБРАТЬ
						  //|	КредитыЗолотаяКоронаВПС.Ссылка
						  //|ИЗ
						  //|	Документ.КредитыЗолотаяКоронаВПС КАК КредитыЗолотаяКоронаВПС
						  //|ГДЕ
						  //|	КредитыЗолотаяКоронаВПС.Проведен = ""Ложь""
						  //|	И КредитыЗолотаяКоронаВПС.Дата МЕЖДУ &ДатаН И &ДатаК";
		ЗапросПОДокам.УстановитьПараметр("ДатаН", НачалоДня(ДатаН));
		ЗапросПОДокам.УстановитьПараметр("ДатаК", КонецДня(ДатаК));
		Результат = ЗапросПОДокам.Выполнить().Выбрать();
		Если Результат.Количество() > 0 Тогда
			Пока Результат.Следующий() цикл
				Попытка
				
					док = Результат.Возврат.ПолучитьОбъект();
					док.Записать(РежимЗаписиДокумента.Проведение);
				    док1 = Результат.Платеж.ПолучитьОбъект();
					док1.Записать(РежимЗаписиДокумента.Проведение);

				Исключение
					#Если Клиент Тогда
				    	//Сообщить("Не удалось провести документ: "+ док+Символы.ПС+ОписаниеОшибки());
					#КонецЕсли
				КонецПопытки;
			КонецЦикла;
		КонецЕсли;
	КонецПроцедуры

Процедура ПровестиДокиПлатежиКибер(ДатаН, ДатаК) Экспорт 
	ЗапросПОДокам = новый Запрос();
	ЗапросПОДокам.Текст = "ВЫБРАТЬ
						  |	ПлатежиВКиберплате.Ссылка
						  |ИЗ
						  |	Документ.ПлатежиВКиберплате КАК ПлатежиВКиберплате
						  |ГДЕ
						  |	ПлатежиВКиберплате.Проведен = Ложь
						  |	И ПлатежиВКиберплате.Дата МЕЖДУ &ДатаН И &ДатаК";
						  //|
						  //|ОБЪЕДИНИТЬ ВСЕ
						  //|
						  //|ВЫБРАТЬ
						  //|	ПриемПлатежей.Ссылка
						  //|ИЗ
						  //|	Документ.ПриемПлатежей КАК ПриемПлатежей
						  //|ГДЕ
						  //|	ПриемПлатежей.Проведен = Ложь
						  //|	И ПриемПлатежей.Дата МЕЖДУ &ДатаН И &ДатаК
						  //|
						  //|ОБЪЕДИНИТЬ ВСЕ
						  //|
						  //|ВЫБРАТЬ
						  //|	ЗолотаяКоронаВПС.Ссылка
						  //|ИЗ
						  //|	Документ.ЗолотаяКоронаВПС КАК ЗолотаяКоронаВПС
						  //|ГДЕ
						  //|	ЗолотаяКоронаВПС.Проведен = ""Ложь""
						  //|	И ЗолотаяКоронаВПС.Дата МЕЖДУ &ДатаН И &ДатаК
						  //|
						  //|ОБЪЕДИНИТЬ ВСЕ
						  //|
						  //|ВЫБРАТЬ
						  //|	ПриемПлатежейЗК.Ссылка
						  //|ИЗ
						  //|	Документ.ПриемПлатежейЗК КАК ПриемПлатежейЗК
						  //|ГДЕ
						  //|	ПриемПлатежейЗК.Проведен = ""Ложь""
						  //|	И ПриемПлатежейЗК.Дата МЕЖДУ &ДатаН И &ДатаК
						  //|
						  //|ОБЪЕДИНИТЬ ВСЕ
						  //|
						  //|ВЫБРАТЬ
						  //|	КредитыЗолотаяКоронаЛП.Ссылка
						  //|ИЗ
						  //|	Документ.КредитыЗолотаяКоронаЛП КАК КредитыЗолотаяКоронаЛП
						  //|ГДЕ
						  //|	КредитыЗолотаяКоронаЛП.Проведен = Ложь
						  //|	И КредитыЗолотаяКоронаЛП.Дата МЕЖДУ &ДатаН И &ДатаК";
						  //|
						  //|ОБЪЕДИНИТЬ ВСЕ
						  //|
						  //|ВЫБРАТЬ
						  //|	КредитыЗолотаяКоронаВПС.Ссылка
						  //|ИЗ
						  //|	Документ.КредитыЗолотаяКоронаВПС КАК КредитыЗолотаяКоронаВПС
						  //|ГДЕ
						  //|	КредитыЗолотаяКоронаВПС.Проведен = ""Ложь""
						  //|	И КредитыЗолотаяКоронаВПС.Дата МЕЖДУ &ДатаН И &ДатаК";
		ЗапросПОДокам.УстановитьПараметр("ДатаН", НачалоДня(ДатаН));
		ЗапросПОДокам.УстановитьПараметр("ДатаК", КонецДня(ДатаК));
		Результат = ЗапросПОДокам.Выполнить().Выбрать();
		Если Результат.Количество() > 0 Тогда
			Пока Результат.Следующий() цикл
				Попытка
				
					док = Результат.Ссылка.ПолучитьОбъект();
					док.Записать(РежимЗаписиДокумента.Проведение);
				
				Исключение
					#Если Клиент Тогда
				    	Сообщить("Не удалось провести документ: "+ док+Символы.ПС+ОписаниеОшибки());
					#КонецЕсли
				КонецПопытки;
			КонецЦикла;
		КонецЕсли;
	КонецПроцедуры
