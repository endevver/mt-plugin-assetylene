package Assetylene::Tags;

use strict;
use warnings;

sub align {
    my ( $ctx, $args ) = @_;
    my $a = $ctx->stash('asset')
        or return $ctx->_no_asset_error();
    return $a->{column_values}->{align} || 'none';
}

sub caption {
    my ( $ctx, $args ) = @_;
    my $a = $ctx->stash('asset')
        or return $ctx->_no_asset_error();
    return $a->{column_values}->{caption} || '';
}

sub default_html {
    my ( $ctx, $args ) = @_;
    my $a = $ctx->stash('asset')
        or return $ctx->_no_asset_error();
    return $a->{column_values}->{default_html} || '';
}

sub enclose {
    my ( $ctx, $args ) = @_;
    my $a = $ctx->stash('asset')
        or return $ctx->_no_asset_error();
    return $a->{column_values}->{enclose} || 1;
}

sub include {
    my ( $ctx, $args ) = @_;
    my $a = $ctx->stash('asset')
        or return $ctx->_no_asset_error();
    return $a->{column_values}->{include} || 1;
}

sub new_entry {
    my ( $ctx, $args ) = @_;
    my $a = $ctx->stash('asset')
        or return $ctx->_no_asset_error();
    return $a->{column_values}->{new_entry} || 1;
}

sub popup {
    my ( $ctx, $args ) = @_;
    my $a = $ctx->stash('asset')
        or return $ctx->_no_asset_error();
    return $a->{column_values}->{popup} || 0;
}

sub thumb {
    my ( $ctx, $args ) = @_;
    my $a = $ctx->stash('asset')
        or return $ctx->_no_asset_error();
    return $a->{column_values}->{thumb} || 0;
}

sub thumb_width {
    my ( $ctx, $args ) = @_;
    my $a = $ctx->stash('asset')
        or return $ctx->_no_asset_error();
    return $a->{column_values}->{thumb_width} || 0;
}

sub wrap_text {
    my ( $ctx, $args ) = @_;
    my $a = $ctx->stash('asset')
        or return $ctx->_no_asset_error();
    return $a->{column_values}->{wrap_text} || 1;
}

1;

__END__
