/**
 * @name Number of classes
 * @description Files with a large number of classes are difficult to read. Additionally the structure of the project is not reflected in the file system.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 * @deprecated
 */
import csharp

from SourceFile f, int n
where n = count(Class c | c.getFile() = f and c.isSourceDeclaration())
select f, n
order by n desc
