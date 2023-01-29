
use v5.16;
use utf8;
use Lingua::Stem::UniNE::CS qw(stem_cs);

my $text = <<END;
Příběh první publikované části Clavellovy „asijské ságy“ se odehrává v polovině předminulého 
století, v době, kdy Velká Británie získala od Číny ostrov jménem Hongkong. Je to sice pusté a 
nehostinné místo, ale má strategickou pozici u čínských břehů a navíc jde o dokonale chráněný 
přístav. A právě tady se rozhoduje o dalším osudu obchodních a politických vztahů Británie s Čínou, 
které se točí kolem opia, čaje a stříbra. Velkou roli v nich hraje Dirk Struan, vlastník největší 
soukromé námořní flotily v Asii: bojuje se svými konkurenty o zisky z legálního i pokoutního 
obchodu, tahá za nitky i v nejvyšších kruzích a zároveň se snaží posílit dosud vratké a nejisté 
postavení vznikající hongkongské kolonie v Asii i ve vzdálené, ale mocné Anglii. Struan je jedním z 
těch, kdo nepovažují Číňany za nevzdělané barbary, ale jsou schopni ocenit a respektovat jejich 
kulturu a životní styl. V lecčem dokonce dává přednost Číně před Anglií, ale ani on si nemůže 
dovolit představit společnosti svou čínskou milenku Mej-Mej, chce-li si udržet výsadní postavení. 
Dirk Struan má syna a touží po tom, aby se Culum stal jeho nástupcem - tchaj-panem, nejvyšším 
vládcem firmy, a tím i nejbohatší a nejmocnější osobou v Hongkongu. Ale syna má i Struanův 
nejsilnější obchodní protivník a odvěký nepřítel Brock. Půjdou jejich děti ve šlépějích otců, nebo 
si najdou vlastní cestu?
END

binmode(STDOUT, ':utf8');
while($text =~ /(\w+)/gs) {
    say "$1 = " . stem_cs($1);
}

