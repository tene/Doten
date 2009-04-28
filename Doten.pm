module Doten::EXPORT::DEFAULT { }

module Doten {
    our @events;

    ::Doten::EXPORT::DEFAULT<!sub_trait_event-handler> = sub ($trait, $block, $arg) {
        my %ns := $block.get_namespace();
        my $event;
        if defined($arg) {
            $event = ~$arg;
        }
        else {
            $event = ~$block;
        }
        unless defined(%ns<states>) {
            %ns<states> = hash();
        }
        %ns<states>{$event} = $block;
    }

    sub enqueue (Code $callback) {
        @events.push($callback);
    }

    sub step () {
        return unless @events;
        my $callback = shift @events;
        return $callback();
    }

    sub run () {
        while @events {
            step;
        }
    }

    sub post($session, Str $event, *@args, *%named_args) is export  {
        my $cb = sub {
                $session.dispatch($event, |@args, |%named_args);
            };
        @events.push($cb);
    }

    class Session {
        method post(Str $event, *@args, *%named_args) {
            Doten::post(self, $event, |@args, |%named_args);
        }
        method dispatch (Str $event, *@args, *%named_args) {
            my %ns := self.HOW.get_parrotclass(self).get_namespace();
            my $handler = %ns<states>{$event};
            if defined($handler) {
                self.$handler(|@args, |%named_args);
            }
            else {
                warn "unhandled event: $event";
            }
        }
    }

}
