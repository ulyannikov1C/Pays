﻿
	

Процедура КнопкаВыполнитьНажатие(Кнопка)
	
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
			Запрос.УстановитьПараметр("Дата1", НачалоДня(ДатаС-60*60*24));
			Запрос.УстановитьПараметр("Дата2", КонецДня(ДатаПо));
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
	
	
	
КонецПроцедуры
