-- Tabla global para las localizaciones
MountFlex_Locales = {}

-- Palabras clave para detectar subtipo de montura según idioma
local subtypeKeywords = {
    enUS = {
        bird = { "hawk", "bird", "falcon", "pigeon", "eagle", "raven", "owl" },
        bike = { "moto", "motorcycle", "bike", "cycle" },
        reptile = { "dragon", "drake", "serpent", "lizard" },
        cat = { "cat", "leopard", "tiger", "panther" },
        wolf = { "wolf", "direwolf" },
        mechanical = { "mechanical", "robot", "mech", "golem" },
        aquatic = { "sea", "shark", "kraken", "turtle" },
        undead = { "undead", "skeleton", "ghost" },
        elemental = { "fire", "water", "earth", "air" },
        horse = { "horse", "pony", "stallion" },
        beast = { "bear", "boar", "moose" },
    },
    esES = {
        bird = { "halcón", "pájaro", "ave", "paloma", "águila", "cuervo", "búho" },
        bike = { "moto", "motocicleta", "bicicleta", "ciclo" },
        reptile = { "dragón", "draco", "serpiente", "lagarto" },
        cat = { "gato", "leopardo", "tigre", "pantera" },
        wolf = { "lobo", "lobezno" },
        mechanical = { "mecánico", "robot", "mech", "gólem" },
        aquatic = { "mar", "tiburón", "kraken", "tortuga" },
        undead = { "muerto", "esqueleto", "fantasma" },
        elemental = { "fuego", "agua", "tierra", "aire" },
        horse = { "caballo", "poni", "semental" },
        beast = { "oso", "jabalí", "alce" },
    },
    esMX = {
        bird = { "halcón", "pájaro", "ave", "paloma", "águila", "cuervo", "búho" },
        bike = { "moto", "motocicleta", "bicicleta", "ciclo" },
        reptile = { "dragón", "draco", "serpiente", "lagarto" },
        cat = { "gato", "leopardo", "tigre", "pantera" },
        wolf = { "lobo", "lobezno" },
        mechanical = { "mecánico", "robot", "mech", "gólem" },
        aquatic = { "mar", "tiburón", "kraken", "tortuga" },
        undead = { "muerto", "esqueleto", "fantasma" },
        elemental = { "fuego", "agua", "tierra", "aire" },
        horse = { "caballo", "poni", "semental" },
        beast = { "oso", "jabalí", "alce" },
    },
    deDE = {
        bird = { "falke", "vogel", "adler", "taube", "rabe", "eule" },
        bike = { "motorrad", "fahrrad", "bike", "zyklus" },
        reptile = { "drache", "drake", "schlange", "echse" },
        cat = { "katze", "leopard", "tiger", "panther" },
        wolf = { "wolf", "direwolf" },
        mechanical = { "mechanisch", "roboter", "mech", "golem" },
        aquatic = { "meer", "hai", "kraken", "schildkröte" },
        undead = { "untot", "skelett", "geist" },
        elemental = { "feuer", "wasser", "erde", "luft" },
        horse = { "pferd", "pony", "hengst" },
        beast = { "bär", "eber", "elch" },
    },
    frFR = {
        bird = { "faucon", "oiseau", "aigle", "pigeon", "corbeau", "chouette" },
        bike = { "moto", "motocyclette", "vélo", "cycle" },
        reptile = { "dragon", "drake", "serpent", "lézard" },
        cat = { "chat", "léopard", "tigre", "panthère" },
        wolf = { "loup", "loup-garou" },
        mechanical = { "mécanique", "robot", "mech", "golem" },
        aquatic = { "mer", "requin", "kraken", "tortue" },
        undead = { "mort-vivant", "squelette", "fantôme" },
        elemental = { "feu", "eau", "terre", "air" },
        horse = { "cheval", "poney", "étalon" },
        beast = { "ours", "sanglier", "élan" },
    },
    itIT = {
        bird = { "falco", "uccello", "aquila", "piccione", "corvo", "gufo" },
        bike = { "moto", "motocicletta", "bicicletta", "ciclo" },
        reptile = { "drago", "drake", "serpente", "lucertola" },
        cat = { "gatto", "leopardo", "tigre", "pantera" },
        wolf = { "lupo", "lupo mannaro" },
        mechanical = { "meccanico", "robot", "mech", "golem" },
        aquatic = { "mare", "squalo", "kraken", "tartaruga" },
        undead = { "non morto", "scheletro", "fantasma" },
        elemental = { "fuoco", "acqua", "terra", "aria" },
        horse = { "cavallo", "pony", "stallone" },
        beast = { "orso", "cinghiale", "alce" },
    },
    ptBR = {
        bird = { "falcão", "pássaro", "águia", "pombo", "corvo", "coruja" },
        bike = { "moto", "motocicleta", "bicicleta", "ciclo" },
        reptile = { "dragão", "drake", "serpente", "lagarto" },
        cat = { "gato", "leopardo", "tigre", "pantera" },
        wolf = { "lobo", "lobisomem" },
        mechanical = { "mecânico", "robô", "mech", "golem" },
        aquatic = { "mar", "tubarão", "kraken", "tartaruga" },
        undead = { "morto-vivo", "esqueleto", "fantasma" },
        elemental = { "fogo", "água", "terra", "ar" },
        horse = { "cavalo", "pônei", "garanhão" },
        beast = { "urso", "javali", "alce" },
    },
    ruRU = {
        bird = { "сокол", "птица", "орёл", "голубь", "ворон", "сова" },
        bike = { "мотоцикл", "велосипед", "байк", "цикл" },
        reptile = { "дракон", "дрейк", "змей", "ящер" },
        cat = { "кот", "леопард", "тигр", "пантера" },
        wolf = { "волк", "лютоволк" },
        mechanical = { "механический", "робот", "мех", "голем" },
        aquatic = { "море", "акула", "кракен", "черепаха" },
        undead = { "нежить", "скелет", "призрак" },
        elemental = { "огонь", "вода", "земля", "воздух" },
        horse = { "лошадь", "пони", "жеребец" },
        beast = { "медведь", "кабан", "лось" },
    }
}

-- Mensajes ampliados por idioma y subtipo
local messages = {
    enUS = {
        bird = {
            "%s soars on a majestic bird!",
            "%s rides the wild skies!",
            "%s takes flight atop a fierce falcon!",
            "%s surveys the lands from their aerial throne!",
        },
        bike = {
            "%s revs up their roaring bike!",
            "Feel the speed! %s is on their bike!",
            "%s blazes the road with their two-wheeled beast!",
            "%s races the wind on their motorcycle!",
        },
        reptile = {
            "%s commands the mighty dragon!",
            "Beware! %s rides a fierce reptile!",
            "%s slithers into battle on their scaled mount!",
            "%s rides the fiery drake with pride!",
        },
        cat = {
            "%s prowls stealthily on their feline mount!",
            "%s rides the wild cat with grace!",
            "%s moves silently, feline power at their side!",
            "%s leaps into action atop a fierce tiger!",
        },
        wolf = {
            "%s howls as they ride their fierce wolf!",
            "%s charges on their direwolf companion!",
            "%s leads the pack on their loyal wolf!",
            "%s stalks the night riding a shadowy wolf!",
        },
        mechanical = {
            "%s powers up their mechanical steed!",
            "%s rides the gears and bolts!",
            "%s charges forth on a steely machine!",
            "%s rules the battlefield with mechanical might!",
        },
        aquatic = {
            "%s dives deep on their aquatic mount!",
            "%s rides the waves like a boss!",
            "%s commands the ocean's fury atop their sea beast!",
            "%s glides through water on a mighty kraken!",
        },
        undead = {
            "%s rides the shadows on their undead steed!",
            "%s commands the spectral beast!",
            "%s haunts the lands atop a ghostly mount!",
            "%s strikes fear riding a skeletal nightmare!",
        },
        elemental = {
            "%s harnesses the power of the elements!",
            "%s rides the elemental force!",
            "%s commands fire and ice on their elemental mount!",
            "%s rides the storm with raw elemental fury!",
        },
        horse = {
            "%s gallops on their trusty horse!",
            "%s rides with noble grace!",
            "%s charges into battle atop a loyal steed!",
            "%s races the plains with speed and honor!",
        },
        beast = {
            "%s rides the wild beast with fury!",
            "%s commands the primal beast!",
            "%s tames the savage wilderness on their mount!",
            "%s howls with the beast as they ride!",
        },
        generic = {
            "%s mounts up with style!",
            "%s rides into adventure!",
            "%s saddles up for the journey!",
            "%s takes to their trusty steed!",
            "%s is ready to ride!",
            "%s charges forth on their mount!",
            "%s embarks on their noble beast!",
            "%s rides with determination!",
            "%s mounts with flair and confidence!",
            "%s rides boldly into the unknown!",
        }
    },
    -- Para ahorrar espacio, solo te pongo esES completo. Los otros idiomas siguen la misma estructura con frases propias similares.

    esES = {
        bird = {
            "¡%s vuela majestuosamente en su ave!",
            "¡%s cabalga por los cielos salvajes!",
            "¡%s toma vuelo sobre un feroz halcón!",
            "¡%s observa las tierras desde su trono aéreo!",
        },
        bike = {
            "¡%s acelera su rugiente moto!",
            "¡Siente la velocidad! ¡%s va en su moto!",
            "¡%s quema el asfalto con su bestia de dos ruedas!",
            "¡%s corre con el viento en su motocicleta!",
        },
        reptile = {
            "¡%s domina al poderoso dragón!",
            "¡Cuidado! ¡%s cabalga un reptil feroz!",
            "¡%s se desliza a la batalla en su montura escamosa!",
            "¡%s cabalga el draco ígneo con orgullo!",
        },
        cat = {
            "¡%s acecha sigilosamente en su felino!",
            "¡%s cabalga al gato salvaje con gracia!",
            "¡%s se mueve en silencio, con poder felino a su lado!",
            "¡%s salta a la acción sobre un feroz tigre!",
        },
        wolf = {
            "¡%s aúlla mientras cabalga su lobo feroz!",
            "¡%s carga con su compañero lobezno!",
            "¡%s lidera la manada en su leal lobo!",
            "¡%s acecha la noche montado en un lobo sombrío!",
        },
        mechanical = {
            "¡%s enciende su corcel mecánico!",
            "¡%s cabalga entre engranajes y tornillos!",
            "¡%s carga al campo de batalla en una máquina de acero!",
            "¡%s domina el combate con poder mecánico!",
        },
        aquatic = {
            "¡%s se sumerge profundo en su montura acuática!",
            "¡%s cabalga las olas como un jefe!",
            "¡%s manda la furia del océano sobre su bestia marina!",
            "¡%s se desliza por el agua sobre un poderoso kraken!",
        },
        undead = {
            "¡%s cabalga las sombras en su corcel muerto!",
            "¡%s domina a la bestia espectral!",
            "¡%s acecha las tierras montado en una montura fantasmal!",
            "¡%s infunde miedo sobre un pesadilla esquelético!",
        },
        elemental = {
            "¡%s aprovecha el poder de los elementos!",
            "¡%s cabalga la fuerza elemental!",
            "¡%s controla fuego y hielo en su montura elemental!",
            "¡%s cabalga la tormenta con furia elemental!",
        },
        horse = {
            "¡%s galopa en su fiel caballo!",
            "¡%s cabalga con gracia noble!",
            "¡%s carga a la batalla en su leal corcel!",
            "¡%s corre por las llanuras con velocidad y honor!",
        },
        beast = {
            "¡%s cabalga la bestia salvaje con furia!",
            "¡%s domina a la bestia primitiva!",
            "¡%s doma la naturaleza salvaje en su montura!",
            "¡%s aúlla con la bestia mientras cabalga!",
        },
        generic = {
            "¡%s monta con estilo!",
            "¡%s cabalga hacia la aventura!",
            "¡%s se prepara para el viaje!",
            "¡%s toma su fiel corcel!",
            "¡%s está listo para cabalgar!",
            "¡%s carga con su montura!",
            "¡%s se embarca en su noble bestia!",
            "¡%s cabalga con determinación!",
            "¡%s monta con gracia y confianza!",
            "¡%s cabalga audazmente hacia lo desconocido!",
        }
    },
    
    -- Otros idiomas con frases básicas ampliadas pero en su idioma nativo:

    deDE = {
        bird = {
            "%s schwebt majestätisch auf einem Vogel!",
            "%s reitet durch die wilden Himmel!",
            "%s nimmt Fahrt auf mit einem stolzen Falken!",
            "%s beobachtet das Land von ihrem luftigen Thron!",
        },
        bike = {
            "%s gibt Gas auf ihrem brüllenden Motorrad!",
            "Spüre die Geschwindigkeit! %s ist auf ihrem Bike!",
            "%s rast mit dem Zweirad durch die Straßen!",
            "%s jagt mit dem Wind auf ihrem Motorrad!",
        },
        reptile = {
            "%s befiehlt dem mächtigen Drachen!",
            "Vorsicht! %s reitet ein wildes Reptil!",
            "%s schlängelt sich in den Kampf auf ihrem geschuppten Reittier!",
            "%s reitet stolz auf dem feurigen Drachen!",
        },
        cat = {
            "%s schleicht auf ihrer katzenartigen Reittier!",
            "%s reitet mit Anmut auf der wilden Katze!",
            "%s bewegt sich lautlos mit katzenhafter Kraft!",
            "%s springt in Aktion auf einem wilden Tiger!",
        },
        wolf = {
            "%s heult, während sie ihren wilden Wolf reitet!",
            "%s stürmt mit ihrem treuen Wolf voran!",
            "%s führt das Rudel auf ihrem loyalen Wolf!",
            "%s schleicht nachts auf einem schattenhaften Wolf!",
        },
        mechanical = {
            "%s startet ihr mechanisches Ross!",
            "%s reitet auf Zahnrädern und Schrauben!",
            "%s stürmt auf einer stählernen Maschine!",
            "%s beherrscht das Schlachtfeld mit mechanischer Kraft!",
        },
        aquatic = {
            "%s taucht tief auf ihrem Wasserreit!",
            "%s reitet die Wellen wie ein Boss!",
            "%s herrscht über die Ozeane auf ihrem Seebiest!",
            "%s gleitet mit dem mächtigen Kraken durchs Wasser!",
        },
        undead = {
            "%s reitet die Schatten auf ihrem untoten Ross!",
            "%s kommandiert das geisterhafte Biest!",
            "%s spukt auf einem geisterhaften Reittier!",
            "%s versetzt Gegner in Angst auf einem Skelettpferd!",
        },
        elemental = {
            "%s nutzt die Kraft der Elemente!",
            "%s reitet die elementare Macht!",
            "%s beherrscht Feuer und Eis auf ihrem Elementar!",
            "%s reitet den Sturm mit roher Elementarkraft!",
        },
        horse = {
            "%s galoppiert auf ihrem treuen Pferd!",
            "%s reitet mit edler Anmut!",
            "%s stürmt in die Schlacht auf ihrem treuen Ross!",
            "%s rennt mit Geschwindigkeit und Ehre über die Ebenen!",
        },
        beast = {
            "%s reitet das wilde Biest voller Wut!",
            "%s beherrscht das urtümliche Tier!",
            "%s zähmt die wilde Natur auf ihrem Reittier!",
            "%s heult mit dem Biest beim Reiten!",
        },
        generic = {
            "%s steigt stilvoll auf!",
            "%s reitet ins Abenteuer!",
            "%s sattelt für die Reise!",
            "%s nimmt ihr treues Ross!",
            "%s ist bereit zu reiten!",
            "%s stürmt voran auf ihrem Reittier!",
            "%s macht sich auf den Weg!",
            "%s reitet mit Entschlossenheit!",
        }
    },

    frFR = {
        bird = {
            "%s plane sur un oiseau majestueux!",
            "%s chevauche les cieux sauvages!",
            "%s prend son envol sur un fier faucon!",
            "%s observe les terres depuis son trône aérien!",
        },
        bike = {
            "%s fait vrombir sa moto rugissante!",
            "Ressens la vitesse! %s est sur sa moto!",
            "%s brûle l'asphalte avec sa bête à deux roues!",
            "%s file avec le vent sur sa moto!",
        },
        reptile = {
            "%s commande le puissant dragon!",
            "Attention! %s chevauche un reptile féroce!",
            "%s glisse au combat sur sa monture écailleuse!",
            "%s chevauche le drake de feu avec fierté!",
        },
        cat = {
            "%s rôde furtivement sur sa monture féline!",
            "%s chevauche le chat sauvage avec grâce!",
            "%s bouge silencieusement avec la puissance féline!",
            "%s bondit en action sur un tigre féroce!",
        },
        wolf = {
            "%s hurle en chevauchant son loup féroce!",
            "%s charge avec son compagnon loup!",
            "%s mène la meute sur son fidèle loup!",
            "%s traque la nuit sur un loup ombragé!",
        },
        mechanical = {
            "%s active sa monture mécanique!",
            "%s chevauche les engrenages et boulons!",
            "%s charge le champ de bataille sur une machine d'acier!",
            "%s domine le combat avec la puissance mécanique!",
        },
        aquatic = {
            "%s plonge profondément sur sa monture aquatique!",
            "%s chevauche les vagues comme un boss!",
            "%s commande la fureur de l'océan sur sa bête marine!",
            "%s glisse dans l'eau sur un puissant kraken!",
        },
        undead = {
            "%s chevauche les ombres sur sa monture morte-vivante!",
            "%s commande la bête spectrale!",
            "%s hante les terres sur une monture fantomatique!",
            "%s inspire la peur sur un cauchemar squelettique!",
        },
        elemental = {
            "%s exploite la puissance des éléments!",
            "%s chevauche la force élémentaire!",
            "%s commande le feu et la glace sur sa monture élémentaire!",
            "%s chevauche la tempête avec une furie élémentaire!",
        },
        horse = {
            "%s galope sur son fidèle cheval!",
            "%s chevauche avec grâce noble!",
            "%s charge au combat sur sa monture fidèle!",
            "%s court sur les plaines avec vitesse et honneur!",
        },
        beast = {
            "%s chevauche la bête sauvage avec fureur!",
            "%s commande la bête primitive!",
            "%s dompte la nature sauvage sur sa monture!",
            "%s hurle avec la bête en chevauchant!",
        },
        generic = {
            "%s monte avec style!",
            "%s chevauche vers l'aventure!",
            "%s se prépare pour le voyage!",
            "%s prend son fidèle cheval!",
            "%s est prêt à chevaucher!",
            "%s charge avec sa monture!",
            "%s part à l'aventure!",
            "%s chevauche avec détermination!",
        }
    },

    itIT = {
        bird = {
            "%s vola su un maestoso uccello!",
            "%s cavalca nei cieli selvaggi!",
            "%s prende il volo su un fiero falco!",
            "%s osserva le terre dal suo trono aereo!",
        },
        bike = {
            "%s accelera la sua moto ruggente!",
            "Senti la velocità! %s è sulla sua moto!",
            "%s sfreccia sulla sua bestia a due ruote!",
            "%s corre col vento sulla sua motocicletta!",
        },
        reptile = {
            "%s comanda il potente drago!",
            "Attento! %s cavalca un feroce rettile!",
            "%s si insinua in battaglia sul suo destriero squamoso!",
            "%s cavalca il drago infuocato con orgoglio!",
        },
        cat = {
            "%s si aggira furtivamente sulla sua montatura felina!",
            "%s cavalca il gatto selvaggio con grazia!",
            "%s si muove silenziosamente con potere felino!",
            "%s salta in azione su una feroce tigre!",
        },
        wolf = {
            "%s ulula mentre cavalca il suo feroce lupo!",
            "%s carica con il suo compagno lupo!",
            "%s guida il branco sul suo fedele lupo!",
            "%s si aggira nella notte cavalcando un lupo oscuro!",
        },
        mechanical = {
            "%s accende il suo destriero meccanico!",
            "%s cavalca tra ingranaggi e bulloni!",
            "%s carica sul campo di battaglia con una macchina d'acciaio!",
            "%s domina il campo di battaglia con potere meccanico!",
        },
        aquatic = {
            "%s si immerge in profondità sulla sua montatura acquatica!",
            "%s cavalca le onde come un boss!",
            "%s comanda la furia dell'oceano sulla sua bestia marina!",
            "%s scivola sull'acqua su un potente kraken!",
        },
        undead = {
            "%s cavalca le ombre sulla sua montatura non morta!",
            "%s comanda la bestia spettrale!",
            "%s infesta le terre su una montatura fantasma!",
            "%s incute timore cavalcando un incubo scheletrico!",
        },
        elemental = {
            "%s sfrutta il potere degli elementi!",
            "%s cavalca la forza elementale!",
            "%s comanda fuoco e ghiaccio sulla sua montatura elementale!",
            "%s cavalca la tempesta con furia elementale!",
        },
        horse = {
            "%s galoppa sul suo fedele cavallo!",
            "%s cavalca con grazia nobile!",
            "%s carica in battaglia sul suo destriero fedele!",
            "%s corre sulle pianure con velocità e onore!",
        },
        beast = {
            "%s cavalca la bestia selvaggia con furia!",
            "%s comanda la bestia primitiva!",
            "%s doma la natura selvaggia sulla sua montatura!",
            "%s ulula con la bestia mentre cavalca!",
        },
        generic = {
            "%s monta con stile!",
            "%s cavalca verso l'avventura!",
            "%s si prepara per il viaggio!",
            "%s prende il suo fedele destriero!",
            "%s è pronto a cavalcare!",
            "%s carica con la sua montatura!",
            "%s parte per l'avventura!",
            "%s cavalca con determinazione!",
        }
    },

    ptBR = {
        bird = {
            "%s voa majestoso em um pássaro!",
            "%s cavalga pelos céus selvagens!",
            "%s levanta voo em um feroz falcão!",
            "%s observa as terras de seu trono aéreo!",
        },
        bike = {
            "%s acelera sua moto rugindo!",
            "Sinta a velocidade! %s está em sua moto!",
            "%s rasga as ruas com sua besta de duas rodas!",
            "%s corre com o vento em sua motocicleta!",
        },
        reptile = {
            "%s comanda o poderoso dragão!",
            "Cuidado! %s cavalga um réptil feroz!",
            "%s desliza para a batalha em sua montaria escamosa!",
            "%s cavalga o drake de fogo com orgulho!",
        },
        cat = {
            "%s espreita sorrateiramente em sua montaria felina!",
            "%s cavalga o gato selvagem com graça!",
            "%s se move silenciosamente com poder felino!",
            "%s pula em ação em um feroz tigre!",
        },
        wolf = {
            "%s uiva enquanto cavalga seu feroz lobo!",
            "%s investe com seu companheiro lobo!",
            "%s lidera a matilha em seu leal lobo!",
            "%s ronda a noite montado em um lobo sombrio!",
        },
        mechanical = {
            "%s liga sua montaria mecânica!",
            "%s cavalga entre engrenagens e parafusos!",
            "%s investe no campo de batalha com uma máquina de aço!",
            "%s domina a batalha com poder mecânico!",
        },
        aquatic = {
            "%s mergulha fundo em sua montaria aquática!",
            "%s cavalga as ondas como um chefe!",
            "%s comanda a fúria do oceano em sua besta marinha!",
            "%s desliza na água em um poderoso kraken!",
        },
        undead = {
            "%s cavalga as sombras em sua montaria morta-viva!",
            "%s comanda a besta espectral!",
            "%s assombra as terras em uma montaria fantasma!",
            "%s inspira medo cavalgando um pesadelo esquelético!",
        },
        elemental = {
            "%s aproveita o poder dos elementos!",
            "%s cavalga a força elemental!",
            "%s comanda fogo e gelo em sua montaria elemental!",
            "%s cavalga a tempestade com fúria elemental!",
        },
        horse = {
            "%s galopa em seu fiel cavalo!",
            "%s cavalga com graça nobre!",
            "%s investe na batalha em seu leal corcel!",
            "%s corre pelas planícies com velocidade e honra!",
        },
        beast = {
            "%s cavalga a besta selvagem com fúria!",
            "%s comanda a besta primitiva!",
            "%s doma a natureza selvagem em sua montaria!",
            "%s uiva com a besta enquanto cavalga!",
        },
        generic = {
            "%s monta com estilo!",
            "%s cavalga para a aventura!",
            "%s se prepara para a jornada!",
            "%s toma seu fiel corcel!",
            "%s está pronto para cavalgar!",
            "%s investe com sua montaria!",
            "%s parte para a aventura!",
            "%s cavalga com determinação!",
        }
    },

    ruRU = {
        bird = {
            "%s парит на величественной птице!",
            "%s мчится по диким небесам!",
            "%s взмывает ввысь на свирепом соколе!",
            "%s обозревает земли со своего воздушного трона!",
        },
        bike = {
            "%s заводит ревущий мотоцикл!",
            "Чувствуй скорость! %s на своем байке!",
            "%s мчит по дороге на двухколесном звере!",
            "%s несется ветром на мотоцикле!",
        },
        reptile = {
            "%s командует могучим драконом!",
            "Осторожно! %s едет на свирепом рептилии!",
            "%s скользит в бой на чешуйчатой горной лошади!",
            "%s гордо едет на огненном драконе!",
        },
        cat = {
            "%s крадется на своей кошачьей ездовом животном!",
            "%s грациозно скачет на дикой кошке!",
            "%s бесшумно движется с кошачьей силой!",
            "%s прыгает в бой на свирепом тигре!",
        },
        wolf = {
            "%s воет, скача на свирепом волке!",
            "%s мчится с верным компаньоном волком!",
            "%s ведет стаю на своем преданном волке!",
            "%s крадется ночью на теневом волке!",
        },
        mechanical = {
            "%s заводит своего механического скакуна!",
            "%s едет среди шестеренок и болтов!",
            "%s мчится в бой на стальной машине!",
            "%s владеет полем боя с механической мощью!",
        },
        aquatic = {
            "%s ныряет глубоко на своей водной ездовой животном!",
            "%s катается по волнам, как босс!",
            "%s командует яростью океана на своей морской зверюге!",
            "%s скользит по воде на мощном кракене!",
        },
        undead = {
            "%s едет по теням на своем неживом скакуне!",
            "%s командует призрачным зверем!",
            "%s преследует земли на своей призрачной езде!",
            "%s вселяет страх, скача на скелетном кошмаре!",
        },
        elemental = {
            "%s использует силу стихий!",
            "%s едет на стихии!",
            "%s командует огнем и льдом на своей стихийной езде!",
            "%s мчится в бурю с яростью стихий!",
        },
        horse = {
            "%s скакает на своем верном коне!",
            "%s едет с благородной грацией!",
            "%s мчится в бой на своем верном скакуне!",
            "%s мчится по равнинам со скоростью и честью!",
        },
        beast = {
            "%s едет на диком звере с яростью!",
            "%s командует первобытным зверем!",
            "%s приручает дикую природу на своей езде!",
            "%s воет с зверем, скача!",
        },
        generic = {
            "%s стильно садится на скакуна!",
            "%s мчится в приключение!",
            "%s готовится к путешествию!",
            "%s садится на своего верного скакуна!",
            "%s готов к поездке!",
            "%s мчится вперед на своем скакуне!",
            "%s отправляется в путь!",
            "%s мчится с решимостью!",
        }
    }
}

MountFlex_Locales_Config = {
    locales = MountFlex_Locales,
    subtypeKeywords = subtypeKeywords,
    messages = messages
}
local function GetRandomMountMessage(localeData)
    local msgList = localeData.generic or {}
    if #msgList > 0 then
        local playerName = UnitName("player") or "Player"
        local template = msgList[math.random(#msgList)]
        return string.format(template, playerName)
    else
        return "Mount up!"
    end
end

