/**
 * Macros for metaprogramming
 * ExtendedC
 *
 * Copyright (C) 2012 Justin Spahr-Summers
 * Released under the MIT license
 */

#ifndef EXTC_METAMACROS_H
#define EXTC_METAMACROS_H


/**
 * Executes one or more expressions (which may have a void type, such as a call
 * to a function that returns no value) and always returns true.
 */
#define bmmetamacro_exprify(...) \
    ((__VA_ARGS__), true)

/**
 * Returns a string representation of VALUE after full macro expansion.
 */
#define bmmetamacro_stringify(VALUE) \
        bmmetamacro_stringify_(VALUE)

/**
 * Returns A and B concatenated after full macro expansion.
 */
#define bmmetamacro_concat(A, B) \
        bmmetamacro_concat_(A, B)

/**
 * Returns the Nth variadic argument (starting from zero). At least
 * N + 1 variadic arguments must be given. N must be between zero and twenty,
 * inclusive.
 */
#define bmmetamacro_at(N, ...) \
        bmmetamacro_concat(bmmetamacro_at, N)(__VA_ARGS__)

/**
 * Returns the number of arguments (up to twenty) provided to the macro. At
 * least one argument must be provided.
 *
 * Inspired by P99: http://p99.gforge.inria.fr
 */
#define bmmetamacro_argcount(...) \
        bmmetamacro_at(20, __VA_ARGS__, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1)

/**
 * Identical to #metamacro_foreach_cxt, except that no CONTEXT argument is
 * given. Only the index and current argument will thus be passed to MACRO.
 */
#define bmmetamacro_foreach(MACRO, SEP, ...) \
        bmmetamacro_foreach_cxt(bmmetamacro_foreach_iter, SEP, MACRO, __VA_ARGS__)

/**
 * For each consecutive variadic argument (up to twenty), MACRO is passed the
 * zero-based index of the current argument, CONTEXT, and then the argument
 * itself. The results of adjoining invocations of MACRO are then separated by
 * SEP.
 *
 * Inspired by P99: http://p99.gforge.inria.fr
 */
#define bmmetamacro_foreach_cxt(MACRO, SEP, CONTEXT, ...) \
        bmmetamacro_concat(bmmetamacro_foreach_cxt, bmmetamacro_argcount(__VA_ARGS__))(MACRO, SEP, CONTEXT, __VA_ARGS__)

/**
 * Identical to #metamacro_foreach_cxt. This can be used when the former would
 * fail due to recursive macro expansion.
 */
#define bmmetamacro_foreach_cxt_recursive(MACRO, SEP, CONTEXT, ...) \
        bmmetamacro_concat(bmmetamacro_foreach_cxt_recursive, bmmetamacro_argcount(__VA_ARGS__))(MACRO, SEP, CONTEXT, __VA_ARGS__)

/**
 * In consecutive order, appends each variadic argument (up to twenty) onto
 * BASE. The resulting concatenations are then separated by SEP.
 *
 * This is primarily useful to manipulate a list of macro invocations into instead
 * invoking a different, possibly related macro.
 */
#define bmmetamacro_foreach_concat(BASE, SEP, ...) \
        bmmetamacro_foreach_cxt(bmmetamacro_foreach_concat_iter, SEP, BASE, __VA_ARGS__)

/**
 * Iterates COUNT times, each time invoking MACRO with the current index
 * (starting at zero) and CONTEXT. The results of adjoining invocations of MACRO
 * are then separated by SEP.
 *
 * COUNT must be an integer between zero and twenty, inclusive.
 */
#define bmmetamacro_for_cxt(COUNT, MACRO, SEP, CONTEXT) \
        bmmetamacro_concat(bmmetamacro_for_cxt, COUNT)(MACRO, SEP, CONTEXT)

/**
 * Returns the first argument given. At least one argument must be provided.
 *
 * This is useful when implementing a variadic macro, where you may have only
 * one variadic argument, but no way to retrieve it (for example, because \c ...
 * always needs to match at least one argument).
 *
 * @code

#define varmacro(...) \
    metamacro_head(__VA_ARGS__)

 * @endcode
 */
#define bmmetamacro_head(...) \
        bmmetamacro_head_(__VA_ARGS__, 0)

/**
 * Returns every argument except the first. At least two arguments must be
 * provided.
 */
#define bmmetamacro_tail(...) \
        bmmetamacro_tail_(__VA_ARGS__)

/**
 * Returns the first N (up to twenty) variadic arguments as a new argument list.
 * At least N variadic arguments must be provided.
 */
#define bmmetamacro_take(N, ...) \
        bmmetamacro_concat(metamacro_take, N)(__VA_ARGS__)

/**
 * Removes the first N (up to twenty) variadic arguments from the given argument
 * list. At least N variadic arguments must be provided.
 */
#define bmmetamacro_drop(N, ...) \
        bmmetamacro_concat(metamacro_drop, N)(__VA_ARGS__)

/**
 * Decrements VAL, which must be a number between zero and twenty, inclusive.
 *
 * This is primarily useful when dealing with indexes and counts in
 * metaprogramming.
 */
#define bmmetamacro_dec(VAL) \
        bmmetamacro_at(VAL, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19)

/**
 * Increments VAL, which must be a number between zero and twenty, inclusive.
 *
 * This is primarily useful when dealing with indexes and counts in
 * metaprogramming.
 */
#define bmmetamacro_inc(VAL) \
        bmmetamacro_at(VAL, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21)

/**
 * If A is equal to B, the next argument list is expanded; otherwise, the
 * argument list after that is expanded. A and B must be numbers between zero
 * and twenty, inclusive. Additionally, B must be greater than or equal to A.
 *
 * @code

// expands to true
metamacro_if_eq(0, 0)(true)(false)

// expands to false
metamacro_if_eq(0, 1)(true)(false)

 * @endcode
 *
 * This is primarily useful when dealing with indexes and counts in
 * metaprogramming.
 */
#define bmmetamacro_if_eq(A, B) \
        bmmetamacro_concat(bmmetamacro_if_eq, A)(B)

/**
 * Identical to #metamacro_if_eq. This can be used when the former would fail
 * due to recursive macro expansion.
 */
#define bmmetamacro_if_eq_recursive(A, B) \
        bmmetamacro_concat(bmmetamacro_if_eq_recursive, A)(B)

/**
 * Returns 1 if N is an even number, or 0 otherwise. N must be between zero and
 * twenty, inclusive.
 *
 * For the purposes of this test, zero is considered even.
 */
#define bmmetamacro_is_even(N) \
        bmmetamacro_at(N, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1)

/**
 * Returns the logical NOT of B, which must be the number zero or one.
 */
#define bmmetamacro_not(B) \
        bmmetamacro_at(B, 1, 0)

// IMPLEMENTATION DETAILS FOLLOW!
// Do not write code that depends on anything below this line.
#define bmmetamacro_stringify_(VALUE) # VALUE
#define bmmetamacro_concat_(A, B) A ## B
#define bmmetamacro_foreach_iter(INDEX, MACRO, ARG) MACRO(INDEX, ARG)
#define bmmetamacro_head_(FIRST, ...) FIRST
#define bmmetamacro_tail_(FIRST, ...) __VA_ARGS__
#define bmmetamacro_consume_(...)
#define bmmetamacro_expand_(...) __VA_ARGS__

// implemented from scratch so that metamacro_concat() doesn't end up nesting
#define bmmetamacro_foreach_concat_iter(INDEX, BASE, ARG) metamacro_foreach_concat_iter_(BASE, ARG)
#define bmmetamacro_foreach_concat_iter_(BASE, ARG) BASE ## ARG

// metamacro_at expansions
#define bmmetamacro_at0(...) bmmetamacro_head(__VA_ARGS__)
#define bmmetamacro_at1(_0, ...) bmmetamacro_head(__VA_ARGS__)
#define bmmetamacro_at2(_0, _1, ...) bmmetamacro_head(__VA_ARGS__)
#define bmmetamacro_at3(_0, _1, _2, ...) bmmetamacro_head(__VA_ARGS__)
#define bmmetamacro_at4(_0, _1, _2, _3, ...) bmmetamacro_head(__VA_ARGS__)
#define bmmetamacro_at5(_0, _1, _2, _3, _4, ...) bmmetamacro_head(__VA_ARGS__)
#define bmmetamacro_at6(_0, _1, _2, _3, _4, _5, ...) bmmetamacro_head(__VA_ARGS__)
#define bmmetamacro_at7(_0, _1, _2, _3, _4, _5, _6, ...) bmmetamacro_head(__VA_ARGS__)
#define bmmetamacro_at8(_0, _1, _2, _3, _4, _5, _6, _7, ...) bmmetamacro_head(__VA_ARGS__)
#define bmmetamacro_at9(_0, _1, _2, _3, _4, _5, _6, _7, _8, ...) bmmetamacro_head(__VA_ARGS__)
#define bmmetamacro_at10(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, ...) bmmetamacro_head(__VA_ARGS__)
#define bmmetamacro_at11(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, ...) bmmetamacro_head(__VA_ARGS__)
#define bmmetamacro_at12(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, ...) bmmetamacro_head(__VA_ARGS__)
#define bmmetamacro_at13(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, ...) bmmetamacro_head(__VA_ARGS__)
#define bmmetamacro_at14(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, ...) bmmetamacro_head(__VA_ARGS__)
#define bmmetamacro_at15(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, ...) bmmetamacro_head(__VA_ARGS__)
#define bmmetamacro_at16(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, ...) bmmetamacro_head(__VA_ARGS__)
#define bmmetamacro_at17(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, ...) bmmetamacro_head(__VA_ARGS__)
#define bmmetamacro_at18(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, ...) bmmetamacro_head(__VA_ARGS__)
#define bmmetamacro_at19(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, ...) bmmetamacro_head(__VA_ARGS__)
#define bmmetamacro_at20(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, ...) bmmetamacro_head(__VA_ARGS__)

// metamacro_foreach_cxt expansions
#define bmmetamacro_foreach_cxt0(MACRO, SEP, CONTEXT)
#define bmmetamacro_foreach_cxt1(MACRO, SEP, CONTEXT, _0) MACRO(0, CONTEXT, _0)

#define bmmetamacro_foreach_cxt2(MACRO, SEP, CONTEXT, _0, _1) \
    bmmetamacro_foreach_cxt1(MACRO, SEP, CONTEXT, _0) \
    SEP \
    MACRO(1, CONTEXT, _1)

#define bmmetamacro_foreach_cxt3(MACRO, SEP, CONTEXT, _0, _1, _2) \
    bmmetamacro_foreach_cxt2(MACRO, SEP, CONTEXT, _0, _1) \
    SEP \
    MACRO(2, CONTEXT, _2)

#define bmmetamacro_foreach_cxt4(MACRO, SEP, CONTEXT, _0, _1, _2, _3) \
    bmmetamacro_foreach_cxt3(MACRO, SEP, CONTEXT, _0, _1, _2) \
    SEP \
    MACRO(3, CONTEXT, _3)

#define bmmetamacro_foreach_cxt5(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4) \
    bmmetamacro_foreach_cxt4(MACRO, SEP, CONTEXT, _0, _1, _2, _3) \
    SEP \
    MACRO(4, CONTEXT, _4)

#define bmmetamacro_foreach_cxt6(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5) \
    bmmetamacro_foreach_cxt5(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4) \
    SEP \
    MACRO(5, CONTEXT, _5)

#define bmmetamacro_foreach_cxt7(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6) \
    bmmetamacro_foreach_cxt6(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5) \
    SEP \
    MACRO(6, CONTEXT, _6)

#define bmmetamacro_foreach_cxt8(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7) \
    bmmetamacro_foreach_cxt7(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6) \
    SEP \
    MACRO(7, CONTEXT, _7)

#define bmmetamacro_foreach_cxt9(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8) \
    bmmetamacro_foreach_cxt8(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7) \
    SEP \
    MACRO(8, CONTEXT, _8)

#define bmmetamacro_foreach_cxt10(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9) \
    bmmetamacro_foreach_cxt9(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8) \
    SEP \
    MACRO(9, CONTEXT, _9)

#define bmmetamacro_foreach_cxt11(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10) \
    bmmetamacro_foreach_cxt10(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9) \
    SEP \
    MACRO(10, CONTEXT, _10)

#define bmmetamacro_foreach_cxt12(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11) \
    bmmetamacro_foreach_cxt11(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10) \
    SEP \
    MACRO(11, CONTEXT, _11)

#define bmmetamacro_foreach_cxt13(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12) \
    bmmetamacro_foreach_cxt12(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11) \
    SEP \
    MACRO(12, CONTEXT, _12)

#define bmmetamacro_foreach_cxt14(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13) \
    bmmetamacro_foreach_cxt13(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12) \
    SEP \
    MACRO(13, CONTEXT, _13)

#define bmmetamacro_foreach_cxt15(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14) \
    bmmetamacro_foreach_cxt14(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13) \
    SEP \
    MACRO(14, CONTEXT, _14)

#define bmmetamacro_foreach_cxt16(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15) \
    bmmetamacro_foreach_cxt15(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14) \
    SEP \
    MACRO(15, CONTEXT, _15)

#define bmmetamacro_foreach_cxt17(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16) \
    bmmetamacro_foreach_cxt16(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15) \
    SEP \
    MACRO(16, CONTEXT, _16)

#define bmmetamacro_foreach_cxt18(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17) \
    bmmetamacro_foreach_cxt17(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16) \
    SEP \
    MACRO(17, CONTEXT, _17)

#define bmmetamacro_foreach_cxt19(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18) \
    bmmetamacro_foreach_cxt18(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17) \
    SEP \
    MACRO(18, CONTEXT, _18)

#define bmmetamacro_foreach_cxt20(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19) \
    bmmetamacro_foreach_cxt19(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18) \
    SEP \
    MACRO(19, CONTEXT, _19)

// bmmetamacro_foreach_cxt_recursive expansions
#define bmmetamacro_foreach_cxt_recursive0(MACRO, SEP, CONTEXT)
#define bmmetamacro_foreach_cxt_recursive1(MACRO, SEP, CONTEXT, _0) MACRO(0, CONTEXT, _0)

#define bmmetamacro_foreach_cxt_recursive2(MACRO, SEP, CONTEXT, _0, _1) \
    bmmetamacro_foreach_cxt_recursive1(MACRO, SEP, CONTEXT, _0) \
    SEP \
    MACRO(1, CONTEXT, _1)

#define bmmetamacro_foreach_cxt_recursive3(MACRO, SEP, CONTEXT, _0, _1, _2) \
    bmmetamacro_foreach_cxt_recursive2(MACRO, SEP, CONTEXT, _0, _1) \
    SEP \
    MACRO(2, CONTEXT, _2)

#define bmmetamacro_foreach_cxt_recursive4(MACRO, SEP, CONTEXT, _0, _1, _2, _3) \
    bmmetamacro_foreach_cxt_recursive3(MACRO, SEP, CONTEXT, _0, _1, _2) \
    SEP \
    MACRO(3, CONTEXT, _3)

#define bmmetamacro_foreach_cxt_recursive5(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4) \
    bmmetamacro_foreach_cxt_recursive4(MACRO, SEP, CONTEXT, _0, _1, _2, _3) \
    SEP \
    MACRO(4, CONTEXT, _4)

#define bmmetamacro_foreach_cxt_recursive6(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5) \
    bmmetamacro_foreach_cxt_recursive5(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4) \
    SEP \
    MACRO(5, CONTEXT, _5)

#define bmmetamacro_foreach_cxt_recursive7(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6) \
    bmmetamacro_foreach_cxt_recursive6(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5) \
    SEP \
    MACRO(6, CONTEXT, _6)

#define bmmetamacro_foreach_cxt_recursive8(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7) \
    bmmetamacro_foreach_cxt_recursive7(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6) \
    SEP \
    MACRO(7, CONTEXT, _7)

#define bmmetamacro_foreach_cxt_recursive9(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8) \
    bmmetamacro_foreach_cxt_recursive8(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7) \
    SEP \
    MACRO(8, CONTEXT, _8)

#define bmmetamacro_foreach_cxt_recursive10(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9) \
    bmmetamacro_foreach_cxt_recursive9(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8) \
    SEP \
    MACRO(9, CONTEXT, _9)

#define bmmetamacro_foreach_cxt_recursive11(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10) \
    bmmetamacro_foreach_cxt_recursive10(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9) \
    SEP \
    MACRO(10, CONTEXT, _10)

#define bmmetamacro_foreach_cxt_recursive12(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11) \
    bmmetamacro_foreach_cxt_recursive11(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10) \
    SEP \
    MACRO(11, CONTEXT, _11)

#define bmmetamacro_foreach_cxt_recursive13(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12) \
    bmmetamacro_foreach_cxt_recursive12(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11) \
    SEP \
    MACRO(12, CONTEXT, _12)

#define bmmetamacro_foreach_cxt_recursive14(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13) \
    bmmetamacro_foreach_cxt_recursive13(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12) \
    SEP \
    MACRO(13, CONTEXT, _13)

#define bmmetamacro_foreach_cxt_recursive15(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14) \
    bmmetamacro_foreach_cxt_recursive14(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13) \
    SEP \
    MACRO(14, CONTEXT, _14)

#define bmmetamacro_foreach_cxt_recursive16(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15) \
    bmmetamacro_foreach_cxt_recursive15(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14) \
    SEP \
    MACRO(15, CONTEXT, _15)

#define bmmetamacro_foreach_cxt_recursive17(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16) \
    bmmetamacro_foreach_cxt_recursive16(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15) \
    SEP \
    MACRO(16, CONTEXT, _16)

#define bmmetamacro_foreach_cxt_recursive18(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17) \
    bmmetamacro_foreach_cxt_recursive17(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16) \
    SEP \
    MACRO(17, CONTEXT, _17)

#define bmmetamacro_foreach_cxt_recursive19(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18) \
    bmmetamacro_foreach_cxt_recursive18(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17) \
    SEP \
    MACRO(18, CONTEXT, _18)

#define bmmetamacro_foreach_cxt_recursive20(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19) \
    bmmetamacro_foreach_cxt_recursive19(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18) \
    SEP \
    MACRO(19, CONTEXT, _19)

// bmmetamacro_for_cxt expansions
#define bmmetamacro_for_cxt0(MACRO, SEP, CONTEXT)
#define bmmetamacro_for_cxt1(MACRO, SEP, CONTEXT) MACRO(0, CONTEXT)

#define bmmetamacro_for_cxt2(MACRO, SEP, CONTEXT) \
    bmmetamacro_for_cxt1(MACRO, SEP, CONTEXT) \
    SEP \
    MACRO(1, CONTEXT)

#define bmmetamacro_for_cxt3(MACRO, SEP, CONTEXT) \
    bmmetamacro_for_cxt2(MACRO, SEP, CONTEXT) \
    SEP \
    MACRO(2, CONTEXT)

#define bmmetamacro_for_cxt4(MACRO, SEP, CONTEXT) \
    bmmetamacro_for_cxt3(MACRO, SEP, CONTEXT) \
    SEP \
    MACRO(3, CONTEXT)

#define bmmetamacro_for_cxt5(MACRO, SEP, CONTEXT) \
    bmmetamacro_for_cxt4(MACRO, SEP, CONTEXT) \
    SEP \
    MACRO(4, CONTEXT)

#define bmmetamacro_for_cxt6(MACRO, SEP, CONTEXT) \
    bmmetamacro_for_cxt5(MACRO, SEP, CONTEXT) \
    SEP \
    MACRO(5, CONTEXT)

#define bmmetamacro_for_cxt7(MACRO, SEP, CONTEXT) \
    bmmetamacro_for_cxt6(MACRO, SEP, CONTEXT) \
    SEP \
    MACRO(6, CONTEXT)

#define bmmetamacro_for_cxt8(MACRO, SEP, CONTEXT) \
    bmmetamacro_for_cxt7(MACRO, SEP, CONTEXT) \
    SEP \
    MACRO(7, CONTEXT)

#define bmmetamacro_for_cxt9(MACRO, SEP, CONTEXT) \
    bmmetamacro_for_cxt8(MACRO, SEP, CONTEXT) \
    SEP \
    MACRO(8, CONTEXT)

#define bmmetamacro_for_cxt10(MACRO, SEP, CONTEXT) \
    bmmetamacro_for_cxt9(MACRO, SEP, CONTEXT) \
    SEP \
    MACRO(9, CONTEXT)

#define bmmetamacro_for_cxt11(MACRO, SEP, CONTEXT) \
    bmmetamacro_for_cxt10(MACRO, SEP, CONTEXT) \
    SEP \
    MACRO(10, CONTEXT)

#define bmmetamacro_for_cxt12(MACRO, SEP, CONTEXT) \
    bmmetamacro_for_cxt11(MACRO, SEP, CONTEXT) \
    SEP \
    MACRO(11, CONTEXT)

#define bmmetamacro_for_cxt13(MACRO, SEP, CONTEXT) \
    bmmetamacro_for_cxt12(MACRO, SEP, CONTEXT) \
    SEP \
    MACRO(12, CONTEXT)

#define bmmetamacro_for_cxt14(MACRO, SEP, CONTEXT) \
    bmmetamacro_for_cxt13(MACRO, SEP, CONTEXT) \
    SEP \
    MACRO(13, CONTEXT)

#define bmmetamacro_for_cxt15(MACRO, SEP, CONTEXT) \
    bmmetamacro_for_cxt14(MACRO, SEP, CONTEXT) \
    SEP \
    MACRO(14, CONTEXT)

#define bmmetamacro_for_cxt16(MACRO, SEP, CONTEXT) \
    bmmetamacro_for_cxt15(MACRO, SEP, CONTEXT) \
    SEP \
    MACRO(15, CONTEXT)

#define bmmetamacro_for_cxt17(MACRO, SEP, CONTEXT) \
    bmmetamacro_for_cxt16(MACRO, SEP, CONTEXT) \
    SEP \
    MACRO(16, CONTEXT)

#define bmmetamacro_for_cxt18(MACRO, SEP, CONTEXT) \
    bmmetamacro_for_cxt17(MACRO, SEP, CONTEXT) \
    SEP \
    MACRO(17, CONTEXT)

#define bmmetamacro_for_cxt19(MACRO, SEP, CONTEXT) \
    bmmetamacro_for_cxt18(MACRO, SEP, CONTEXT) \
    SEP \
    MACRO(18, CONTEXT)

#define bmmetamacro_for_cxt20(MACRO, SEP, CONTEXT) \
    bmmetamacro_for_cxt19(MACRO, SEP, CONTEXT) \
    SEP \
    MACRO(19, CONTEXT)

// bmmetamacro_if_eq expansions
#define bmmetamacro_if_eq0(VALUE) \
    bmmetamacro_concat(bmmetamacro_if_eq0_, VALUE)

#define bmmetamacro_if_eq0_0(...) __VA_ARGS__ bmmetamacro_consume_
#define bmmetamacro_if_eq0_1(...) bmmetamacro_expand_
#define bmmetamacro_if_eq0_2(...) bmmetamacro_expand_
#define bmmetamacro_if_eq0_3(...) bmmetamacro_expand_
#define bmmetamacro_if_eq0_4(...) bmmetamacro_expand_
#define bmmetamacro_if_eq0_5(...) bmmetamacro_expand_
#define bmmetamacro_if_eq0_6(...) bmmetamacro_expand_
#define bmmetamacro_if_eq0_7(...) bmmetamacro_expand_
#define bmmetamacro_if_eq0_8(...) bmmetamacro_expand_
#define bmmetamacro_if_eq0_9(...) bmmetamacro_expand_
#define bmmetamacro_if_eq0_10(...) bmmetamacro_expand_
#define bmmetamacro_if_eq0_11(...) bmmetamacro_expand_
#define bmmetamacro_if_eq0_12(...) bmmetamacro_expand_
#define bmmetamacro_if_eq0_13(...) bmmetamacro_expand_
#define bmmetamacro_if_eq0_14(...) bmmetamacro_expand_
#define bmmetamacro_if_eq0_15(...) bmmetamacro_expand_
#define bmmetamacro_if_eq0_16(...) bmmetamacro_expand_
#define bmmetamacro_if_eq0_17(...) bmmetamacro_expand_
#define bmmetamacro_if_eq0_18(...) bmmetamacro_expand_
#define bmmetamacro_if_eq0_19(...) bmmetamacro_expand_
#define bmmetamacro_if_eq0_20(...) bmmetamacro_expand_

#define bmmetamacro_if_eq1(VALUE) bmmetamacro_if_eq0(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq2(VALUE) bmmetamacro_if_eq1(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq3(VALUE) bmmetamacro_if_eq2(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq4(VALUE) bmmetamacro_if_eq3(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq5(VALUE) bmmetamacro_if_eq4(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq6(VALUE) bmmetamacro_if_eq5(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq7(VALUE) bmmetamacro_if_eq6(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq8(VALUE) bmmetamacro_if_eq7(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq9(VALUE) bmmetamacro_if_eq8(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq10(VALUE) bmmetamacro_if_eq9(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq11(VALUE) bmmetamacro_if_eq10(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq12(VALUE) bmmetamacro_if_eq11(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq13(VALUE) bmmetamacro_if_eq12(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq14(VALUE) bmmetamacro_if_eq13(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq15(VALUE) bmmetamacro_if_eq14(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq16(VALUE) bmmetamacro_if_eq15(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq17(VALUE) bmmetamacro_if_eq16(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq18(VALUE) bmmetamacro_if_eq17(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq19(VALUE) bmmetamacro_if_eq18(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq20(VALUE) bmmetamacro_if_eq19(bmmetamacro_dec(VALUE))

// metamacro_if_eq_recursive expansions
#define bmmetamacro_if_eq_recursive0(VALUE) \
    bmmetamacro_concat(bmmetamacro_if_eq_recursive0_, VALUE)

#define bmmetamacro_if_eq_recursive0_0(...) __VA_ARGS__ bmmetamacro_consume_
#define bmmetamacro_if_eq_recursive0_1(...) bmmetamacro_expand_
#define bmmetamacro_if_eq_recursive0_2(...) bmmetamacro_expand_
#define bmmetamacro_if_eq_recursive0_3(...) bmmetamacro_expand_
#define bmmetamacro_if_eq_recursive0_4(...) bmmetamacro_expand_
#define bmmetamacro_if_eq_recursive0_5(...) bmmetamacro_expand_
#define bmmetamacro_if_eq_recursive0_6(...) bmmetamacro_expand_
#define bmmetamacro_if_eq_recursive0_7(...) bmmetamacro_expand_
#define bmmetamacro_if_eq_recursive0_8(...) bmmetamacro_expand_
#define bmmetamacro_if_eq_recursive0_9(...) bmmetamacro_expand_
#define bmmetamacro_if_eq_recursive0_10(...) bmmetamacro_expand_
#define bmmetamacro_if_eq_recursive0_11(...) bmmetamacro_expand_
#define bmmetamacro_if_eq_recursive0_12(...) bmmetamacro_expand_
#define bmmetamacro_if_eq_recursive0_13(...) bmmetamacro_expand_
#define bmmetamacro_if_eq_recursive0_14(...) bmmetamacro_expand_
#define bmmetamacro_if_eq_recursive0_15(...) bmmetamacro_expand_
#define bmmetamacro_if_eq_recursive0_16(...) bmmetamacro_expand_
#define bmmetamacro_if_eq_recursive0_17(...) bmmetamacro_expand_
#define bmmetamacro_if_eq_recursive0_18(...) bmmetamacro_expand_
#define bmmetamacro_if_eq_recursive0_19(...) bmmetamacro_expand_
#define bmmetamacro_if_eq_recursive0_20(...) bmmetamacro_expand_

#define bmmetamacro_if_eq_recursive1(VALUE) bmmetamacro_if_eq_recursive0(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq_recursive2(VALUE) bmmetamacro_if_eq_recursive1(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq_recursive3(VALUE) bmmetamacro_if_eq_recursive2(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq_recursive4(VALUE) bmmetamacro_if_eq_recursive3(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq_recursive5(VALUE) bmmetamacro_if_eq_recursive4(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq_recursive6(VALUE) bmmetamacro_if_eq_recursive5(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq_recursive7(VALUE) bmmetamacro_if_eq_recursive6(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq_recursive8(VALUE) bmmetamacro_if_eq_recursive7(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq_recursive9(VALUE) bmmetamacro_if_eq_recursive8(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq_recursive10(VALUE) bmmetamacro_if_eq_recursive9(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq_recursive11(VALUE) bmmetamacro_if_eq_recursive10(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq_recursive12(VALUE) bmmetamacro_if_eq_recursive11(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq_recursive13(VALUE) bmmetamacro_if_eq_recursive12(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq_recursive14(VALUE) bmmetamacro_if_eq_recursive13(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq_recursive15(VALUE) bmmetamacro_if_eq_recursive14(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq_recursive16(VALUE) bmmetamacro_if_eq_recursive15(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq_recursive17(VALUE) bmmetamacro_if_eq_recursive16(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq_recursive18(VALUE) bmmetamacro_if_eq_recursive17(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq_recursive19(VALUE) bmmetamacro_if_eq_recursive18(bmmetamacro_dec(VALUE))
#define bmmetamacro_if_eq_recursive20(VALUE) bmmetamacro_if_eq_recursive19(bmmetamacro_dec(VALUE))

// metamacro_take expansions
#define bmmetamacro_take0(...)
#define bmmetamacro_take1(...) bmmetamacro_head(__VA_ARGS__)
#define bmmetamacro_take2(...) bmmetamacro_head(__VA_ARGS__), bmmetamacro_take1(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_take3(...) bmmetamacro_head(__VA_ARGS__), bmmetamacro_take2(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_take4(...) bmmetamacro_head(__VA_ARGS__), bmmetamacro_take3(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_take5(...) bmmetamacro_head(__VA_ARGS__), bmmetamacro_take4(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_take6(...) bmmetamacro_head(__VA_ARGS__), bmmetamacro_take5(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_take7(...) bmmetamacro_head(__VA_ARGS__), bmmetamacro_take6(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_take8(...) bmmetamacro_head(__VA_ARGS__), bmmetamacro_take7(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_take9(...) bmmetamacro_head(__VA_ARGS__), bmmetamacro_take8(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_take10(...) bmmetamacro_head(__VA_ARGS__), bmmetamacro_take9(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_take11(...) bmmetamacro_head(__VA_ARGS__), bmmetamacro_take10(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_take12(...) bmmetamacro_head(__VA_ARGS__), bmmetamacro_take11(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_take13(...) bmmetamacro_head(__VA_ARGS__), bmmetamacro_take12(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_take14(...) bmmetamacro_head(__VA_ARGS__), bmmetamacro_take13(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_take15(...) bmmetamacro_head(__VA_ARGS__), bmmetamacro_take14(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_take16(...) bmmetamacro_head(__VA_ARGS__), bmmetamacro_take15(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_take17(...) bmmetamacro_head(__VA_ARGS__), bmmetamacro_take16(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_take18(...) bmmetamacro_head(__VA_ARGS__), bmmetamacro_take17(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_take19(...) bmmetamacro_head(__VA_ARGS__), bmmetamacro_take18(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_take20(...) bmmetamacro_head(__VA_ARGS__), bmmetamacro_take19(bmmetamacro_tail(__VA_ARGS__))

// metamacro_drop expansions
#define bmmetamacro_drop0(...) __VA_ARGS__
#define bmmetamacro_drop1(...) bmmetamacro_tail(__VA_ARGS__)
#define bmmetamacro_drop2(...) bmmetamacro_drop1(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_drop3(...) bmmetamacro_drop2(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_drop4(...) bmmetamacro_drop3(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_drop5(...) bmmetamacro_drop4(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_drop6(...) bmmetamacro_drop5(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_drop7(...) bmmetamacro_drop6(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_drop8(...) bmmetamacro_drop7(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_drop9(...) bmmetamacro_drop8(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_drop10(...) bmmetamacro_drop9(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_drop11(...) bmmetamacro_drop10(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_drop12(...) bmmetamacro_drop11(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_drop13(...) bmmetamacro_drop12(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_drop14(...) bmmetamacro_drop13(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_drop15(...) bmmetamacro_drop14(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_drop16(...) bmmetamacro_drop15(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_drop17(...) bmmetamacro_drop16(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_drop18(...) bmmetamacro_drop17(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_drop19(...) bmmetamacro_drop18(bmmetamacro_tail(__VA_ARGS__))
#define bmmetamacro_drop20(...) bmmetamacro_drop19(bmmetamacro_tail(__VA_ARGS__))

#endif
