class_name Par
extends RefCounted
## Fare n lavori indipendenti su più processori insieme (28 set 2026: generatore a fasce, pittori del terreno e degli
## alberi). Ogni lavoro deve scrivere solo nella sua parte (una casella sua di un Array preparato prima, un'immagine
## sua) e leggere solo dati che nessuno cambia intanto.
## Dentro il gruppo di thread (per esempio le prove che generano più mondi insieme) i lavori si fanno uno alla volta:
## aspettare un gruppo di thread da dentro un altro può bloccare tutto.


static func each(n: int, job: Callable, label := "lavori in parallelo") -> void:
	if n <= 0:
		return
	if WorkerThreadPool.get_caller_task_id() == -1 and WorkerThreadPool.get_caller_group_id() == -1:
		var g := WorkerThreadPool.add_group_task(job, n, -1, true, label)
		WorkerThreadPool.wait_for_group_task_completion(g)
	else:
		for i in n:
			job.call(i)
