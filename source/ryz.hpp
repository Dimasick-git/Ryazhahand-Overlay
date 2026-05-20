#pragma once
/*
 * ryz.hpp -- facade-include для Ryazhahand-Overlay.
 *
 * При ребрендинге в репозитории прижилось имя <ryz.hpp> для главного
 * заголовка libryazha. Сама библиотека (libryazhahand) сохраняет имя
 * <ultra.hpp> -- так upstream sync проще, а намespace `ult::` остаётся
 * совместим с любыми upstream-форками.
 *
 * Этот файл просто проксирует имя, чтобы существующий код Overlay'я
 * мог продолжать писать `#include <ryz.hpp>` без массовой переправки.
 *
 * Не добавляйте сюда декларации -- если нужно что-то локальное в
 * Overlay, кладите в utils.hpp или новый header.
 *
 * Автор алиаса: Dimasick-git
 * Лицензия: GPL-2.0 (см. LICENSE проекта)
 */
#include <ultra.hpp>
