use Doten;

class Greeter is Doten::Session {
    my @names = <Stephen Stuart Mike Bryan Dax Dave>;
    method start is event-handler('_start') {
        say 'new greeter session';
        post(self, 'greet', @names.pick());
    }
    method greet($name) is event-handler {
        say "Hello $name";
    }
}

Greeter.new().post('_start') for 1..5;

Doten::run();
