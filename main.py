import pandas as pd
import src as eleccionespy

ELECTION_RESULTS_FILE = "./data/resultados-1996-2018.csv"
ELECTOTRAL_ROLL_FILE = "./data/padron-1998-2018.csv"


def main():
    electionResults = pd.read_csv(ELECTION_RESULTS_FILE)
    electionResults = electionResults[["anio", "dep", "depdes", "dis",
                                       "disdes", "zon", "loc", "cand_desc",
                                       "siglas_lista", "votos", "total_votos"]]

    rollDf = pd.read_csv(ELECTOTRAL_ROLL_FILE)
    rollDf = rollDf[["anio", "dep", "depdes", "dis", "disdes", "total"]]
    rollDf = rollDf.rename(columns={"total": "eligible_voters"})
    roll = eleccionespy.ElectoralRoll(rollDf)

    anrMayor = eleccionespy.AnrMayor(electionResults, roll)
    anrMayor.stats()


if __name__ == "__main__":
    main()
