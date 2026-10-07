"""Costruire con uno scopo (Roadmap 47, voce 401; piano in VASTITA.md).

Ogni boss ha il suo **trofeo**: i Guardiani, i capi erranti, gli sfidanti e i superboss lo avevano già; qui quelli degli
otto capi degli eventi (li lascia `FirmaDrops`, una volta su due). Esposto in una sala dei trofei, dà più danno contro
quel boss (`Rooms.trophy_vs`, `RoomsData.boss_of_trophy`).
"""
from vastita_gen.eventi import EVENTS


def build():
    items = {}
    for ev in EVENTS:
        eid, name, boss = ev[0], ev[1], ev[9]
        items['trofeo_evento_' + eid] = {
            'name': 'Trofeo: %s' % (boss[0][0].lower() + boss[0][1:]), 'kind': 'trofeo', 'icon': ['corona', 'brillaluce'],
            'source': 'il capo dell\'evento «%s», una volta su due' % name,
            'desc': 'Esposto in una sala dei trofei, ferisci di più %s.' % (boss[0][0].lower() + boss[0][1:])}
    return [('costruire.gd', 'Roadmap 47, voce 401: i trofei dei capi degli eventi', {'items': items})]
