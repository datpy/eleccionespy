from pandas import DataFrame
from ..mayor import Mayor
from ..roll import ElectoralRoll


class AnrMayor(Mayor):
    def __init__(self, electionResults: DataFrame, roll: ElectoralRoll):
        query = "cand_desc == 'INTENDENTE' & anio == 2015"

        self.mayorResults = electionResults.query(query)
        self.anrMayorResults = self.mayorResults.query("siglas_lista == 'ANR'")

        # Use electoral roll for the general elections as proxy for the local
        # ones.
        self.roll = roll.votersByDistrict(2018)

    def stats(self):
        print(self.mayorResults)
        print(self.anrMayorResults)
        print(self.roll)
