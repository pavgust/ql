var express = require('express');
var Koa = require('koa');

express().get('/some/path', function(req, res) {
    var foo = req.query.foo;
    foo.indexOf(); // NOT OK

    foo.concat(); // NOT OK

    function f() {
        foo.concat(); // NOT OK
    }

    function g(bar) {
        bar.concat(); // NOT OK
    }
    g(foo);

    req.url.indexOf(); // OK

    foo.indexOf(prefix) === 0; // OK
    foo.indexOf(prefix) == 0; // OK
    foo.indexOf(prefix) !== 0; // OK

    foo.slice(-1) === 'x'; // OK

    foo.indexOf(prefix) == 1; // NOT OK
    foo.slice(1) === 'x'; // NOT OK

    if (typeof foo === "string") {
        foo.indexOf(); //  OK
    } else {
        foo.indexOf(); //  OK
    }
    if (foo instanceof Array) {
        foo.indexOf(); //  OK, but still flagged
    }

    (foo + f()).indexOf(); // OK

    foo.length; // NOT OK
});

new Koa().use(function handler(ctx){
    var foo = ctx.request.query.foo;
    foo.indexOf(); // NOT OK
});

express().get('/some/path/:foo', function(req, res) {
    var foo = req.params.foo;
    foo.indexOf(); // OK
});
