package Assetylene::L10N;
use strict;
use base 'MT::Plugin::L10N';

sub init {
    my $lh = shift;
    $lh->SUPER::init(@_);
    $lh->fail_with('mt_fallback');
    return;
}

sub mt_fallback {
    my $lh = shift;
    MT->language_handle->maketext(@_);
}

sub get_handle {
    my $this = shift;
    my ($lang) = @_;
    my $lh;

    # Look up plugin's handle first.  
    # If not available, use system's handle.
    eval { $lh = $this->SUPER::get_handle($lang) ||
        $this->SUPER::get_handle('en_us'); };
    if (!$@ && $lh) {
        return $lh;
    }
    return MT->language_handle;
}

1;

