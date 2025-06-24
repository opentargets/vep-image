#!/usr/bin/env perl
use strict;
use warnings;
use lib 'modules';
use Bio::EnsEMBL::Variation::Utils::Constants;


# Extracting the consequences from Bio::EnsEMBL::Variation::Utils::Constants
# and filtering out those without a valid rank
my @consequences = grep { defined $_->{rank} && $_->{rank} =~ /^\d+$/ } values %Bio::EnsEMBL::Variation::Utils::Constants::OVERLAP_CONSEQUENCES;
my @sorted = sort { $a->{rank} <=> $b->{rank} } @consequences;

# Get max rank from the last sorted element with a valid rank
my $max_rank = 0;
for (my $i = $#sorted; $i >= 0; $i--) {
    if (defined $sorted[$i]{rank} && $sorted[$i]{rank} =~ /^\d+$/) {
        $max_rank = $sorted[$i]{rank};
        last;
    }
}

# Calculate the score based on the formla: score = 1 - (rank / max_rank)
sub calculate_score {
    my ($rank, $max_rank) = @_;
    die "Invalid rank or max_rank: rank=$rank, max_rank=$max_rank\n"
        unless defined $rank && $rank =~ /^\d+$/ && $max_rank > 0;
    return sprintf("%.2f", 1 - ($rank / $max_rank));
}

# Open output file and write header
open my $out, '>', 'so_terms.tsv' or die $!;
print $out "featureId\tterm\tdescription\tdisplayTerm\tfeatureTerm\timpact\trank\tscore\n";

# Write each consequence to the output file
for my $cons (@sorted) {
    my $accession = $cons->{SO_accession} // '';
    my $term      = $cons->{SO_term}      // '';
    my $description = $cons->{description} // '';
    my $display_term = $cons->{display_term} // '';
    my $feature_SO_term = $cons->{feature_SO_term} // '';
    my $impact   = $cons->{impact}       // '';
    my $rank      = $cons->{rank}         // '';
    my $score     = calculate_score($rank, $max_rank);
    print $out "$accession\t$term\t$description\t$display_term\t$feature_SO_term\t$impact\t$rank\t$score\n";
}

close $out;
print "Saved to so_terms.tsv\n";
