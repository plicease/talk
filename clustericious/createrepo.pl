websocket '/createrepo' => sub {
  my($self) = @_;

  my $data = RestYum::Data->new($self->config);
  my $json = Mojo::JSON->new;

  $self->on(finish => sub {
    INFO "connection closed";
  });

  $self->on(message => sub {
    my $self = shift;
    TRACE $_[0];
    my $payload = eval { $json->decode(shift) };
    if(my $error = $@ || !defined $payload)
    {
      ERROR $error;
      $self->send($json->encode({status => 'not ok'}));
      return;
    }

    my $repo_name = $payload->{repo};

    $data->createrepo($repo_name,
      error => sub { $self->send($json->encode({ status => 'not ok', 
                                                 repo => $repo_name })) },
      ok    => sub { $self->send($json->encode({ status => 'ok',
                                                 repo => $repo_name })) },
    );
    return;
  });
} => 'createrepo';
