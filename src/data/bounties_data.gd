class_name BountiesData
extends RefCounted
## Le taglie (Roadmap 25, voce 249; regole in `Bounties`): il Cacciatore di taglie propone sempre `OPEN` cacce a una
## creatura con un nome, più forte, con un tratto antico, in uno strato (e in superficie in un bioma) preciso, da un
## vigore del mondo in su. Arrivati lì, la preda nasce poco lontano (una sola alla volta).

const OPEN := 3
const HP := 2.5                        # la preda ha tanta Vita in più di un'ancestrale della sua specie (e il vigore del mondo)
const DAMAGE := 1.3
const CHECK := 5.0                     # ogni quanti secondi si guarda se si è nel posto di una taglia
const SPAWN_DIST := [22, 34]           # a quante tessere nasce
const REWARD := {"scheggia_vigore": 4, "polvere_iridata": 2}
const REWARD_STEP := 1                 # una scheggia in più ogni 5 taglie compiute (fino al doppio)

## I nomi delle prede: [nome, soprannome]; il nome si sceglie a caso, il soprannome dice il tratto.
const NAMES := ["Grak", "Ossana", "Vetrice", "Morn", "Zilla", "Brunda", "Tarlo", "Suvia", "Kerm", "Lodra", "Fosca", "Gurn",
	"Imbra", "Scarno", "Velta", "Rovo", "Mordo", "Nerla", "Tizzo", "Gelma"]
const TITLES := {"furiosa": "la Furiosa", "corazzata": "Pelle di pietra", "rapida": "Zampa lesta", "gigante": "il Grande",
	"velenosa": "Dente amaro", "spinosa": "Spina viva", "rigenerante": "che non muore", "evocatrice": "Madre di branchi",
	"luminosa": "Occhio di luce", "esplosiva": "Cuore di brace", "evanescente": "l'Ombra"}
