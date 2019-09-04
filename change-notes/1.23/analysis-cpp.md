# Improvements to C/C++ analysis

The following changes in version 1.23 affect C/C++ analysis in all applications.

## General improvements

## New queries

| **Query**                   | **Tags**  | **Purpose**                                                        |
|-----------------------------|-----------|--------------------------------------------------------------------|
| Hard-coded Japanese era start date (`cpp/japanese-era/exact-era-date`) | reliability, japanese-era | This query is a combination of two old queries that were identical in purpose but separate as an implementation detail.  This new query replaces Hard-coded Japanese era start date in call (`cpp/japanese-era/constructor-or-method-with-exact-era-date`) and Hard-coded Japanese era start date in struct (`cpp/japanese-era/struct-with-exact-era-date`). |

## Changes to existing queries

| **Query**                  | **Expected impact**    | **Change**                                                       |
|----------------------------|------------------------|------------------------------------------------------------------|
| Query name (`query id`) | Expected impact | Message. |
| Hard-coded Japanese era start date in call (`cpp/japanese-era/constructor-or-method-with-exact-era-date`) | Deprecated | This query has been deprecated.  Use the new combined query Hard-coded Japanese era start date (`cpp/japanese-era/exact-era-date`) instead. |
| Hard-coded Japanese era start date in struct (`cpp/japanese-era/struct-with-exact-era-date`) | Deprecated | This query has been deprecated.  Use the new combined query Hard-coded Japanese era start date (`cpp/japanese-era/exact-era-date`) instead. |
| Hard-coded Japanese era start date (`cpp/japanese-era/exact-era-date`) | More correct results | This query now checks for the beginning date of the Reiwa era (1st May 2019). |

## Changes to QL libraries

* The data-flow library has been extended with a new feature to aid debugging.
  Instead of specifying `isSink(Node n) { any() }` on a configuration to
  explore the possible flow from a source, it is recommended to use the new
  `Configuration::hasPartialFlow` predicate, as this gives a more complete
  picture of the partial flow paths from a given source. The feature is
  disabled by default and can be enabled for individual configurations by
  overriding `int explorationLimit()`.