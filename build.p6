#!/usr/bin/env perl6

use v6.c;

use Text::Markdown:from<Perl5> 'markdown';
use Template::Mustache;
use YAMLish;
use PathTools;

my $output-dir = 'output';
my $text-out-dir = 'texte';
my $text-dir = 'texts';
my $static-dir = 'static';

sub MAIN( Str :$url-prefix = '' ) {
    my %defaults =
        urlPrefix => $url-prefix
    ;

    rm( $output-dir ) if ! $output-dir.IO.d;
    mkdir $output-dir if ! $output-dir.IO.e;
    rm( $output-dir.IO.dir, :r );

    "$output-dir/css".IO.mkdir;
    for "$static-dir/css".IO.dir { .copy: "$output-dir/css/" ~ $_.basename };
    "$output-dir/js".IO.mkdir;
    for "$static-dir/js".IO.dir { .copy: "$output-dir/js/" ~ $_.basename };
    "$output-dir/fonts".IO.mkdir;
    for "$static-dir/fonts".IO.dir { .copy: "$output-dir/fonts/" ~ $_.basename };
    "$output-dir/texte".IO.mkdir;

    my $mu = Template::Mustache.new: :from<./templates>;

    my @menu-home =
        { :name('Texte'), :link("$url-prefix/texte.html") },
        { :name('Kontakt'), :link("$url-prefix/kontakt.html") },
        ;
    my @menu-texts =
        { :active, :name('Texte'), :link("$url-prefix/texte.html") },
        { :name('Kontakt'), :link("$url-prefix/kontakt.html") },
        ;
    my @menu-text =
        { :name('Texte'), :link("$url-prefix/texte.html") },
        { :name('Kontakt'), :link("$url-prefix/kontakt.html") },
        ;
    my @menu-contact =
        { :name('Texte'), :link("$url-prefix/texte.html") },
        { :active, :name('Kontakt'), :link("$url-prefix/kontakt.html") },
        ;

    spurt $output-dir ~ '/index.html', $mu.render('home', %( |%defaults, menu => @menu-home ));
    spurt $output-dir ~ '/kontakt.html', $mu.render('contact', %( |%defaults, menu => @menu-contact ));

    my @texts;

    # Texts
    for dir $text-dir -> $text {
        if ( $text.basename ~~ m/ ^ (.*)\.md $ / ) {
            my $filecontent = slurp $text;
            my ($, $yaml, $markdown) = $filecontent.split('---', 3).map: *.trim ;
            my %params = load-yaml $yaml;
            my $content = markdown $markdown;

            my $filename = urlify( %params<title> ) ~ '.html';
            my $link-name = "$text-out-dir/$filename";
            my $target = "$output-dir/$link-name";

            my $page = $mu.render('text', %(
                |%defaults,
                menu => @menu-text,
                %params<title>:p,
                originalTitle => %params<original-title>,
                originalLink => %params<original-link>,
                originalDate => %params<original-date>,
                content => $content,
            ));
            spurt $target, $page;

            @texts.push: {
                title => %params<title>,
                link => "$url-prefix/$link-name",
                originalTitle => %params<original-title>,
                originalLink => %params<original-link>,
                originalDate => %params<original-date>
            };
        }
    }

    @texts.sort( { dateFromText( %^a<originalDate> ) <=> dateFromText( %^b<originalDate> )});

    spurt $output-dir ~ '/texte.html', $mu.render('texts-list', %(
        |%defaults,
        menu => @menu-texts,
        texts => @texts
    ));
}

sub urlify(Str $text) {
    my $result = $text;
    $result ~~ s:g/ <-[ a..z A..Z 0..9 _ \s ]>+ //;
    $result ~~ s:g/ <[ \s _ ]>+ /_/;
    return $result;
}

sub dateFromText( Str $text ) {
    $text ~~ m/ (\d**1..2) \. (\d**1..2) \. (\d**4) /;
    my ($day, $month, $year) = $0, $1, $2;
    return Date.new($year, $month, $day);
}

=begin pod

=head1 Todos

=end pod

