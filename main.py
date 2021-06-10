import pandas as pd
import pathlib
import src as eleccionespy

ELECTION_RESULTS_FILE = "./data/resultados-1996-2018.csv"
ELECTOTRAL_ROLL_FILE = "./data/padron-1998-2018.csv"
DEV_INDICATORS_FILE = "./data/indicadores-desarrollo-dep.csv"


def main():
    electionResults = pd.read_csv(ELECTION_RESULTS_FILE)
    electionResults = electionResults[["anio", "dep", "depdes", "dis",
                                       "disdes", "zon", "loc", "cand_desc",
                                       "siglas_lista", "votos", "total_votos"]]

    rollDf = pd.read_csv(ELECTOTRAL_ROLL_FILE)
    rollDf = rollDf[["anio", "dep", "depdes", "dis", "disdes", "total"]]
    rollDf = rollDf.rename(columns={"total": "eligible_voters"})
    roll = eleccionespy.ElectoralRoll(rollDf)

    devIndicators = pd.read_csv(DEV_INDICATORS_FILE)
    devIndicators = devIndicators.query(
        "indicador == 'ECON_IMAP'"
        "| indicador == 'PBRZ_PTOTL'"
        "| indicador == 'PBRZ_NBI'"
        "| indicador == 'SALU_PMNV10-19'"
    )

    stats = eleccionespy.Stats()

    grapher = eleccionespy.Grapher(devIndicators, stats)

    output_dir = pathlib.Path(__file__).parent
    output_dir = output_dir.joinpath("output/graphs").absolute()

    anr_mayor = eleccionespy.AnrMayor(
        grapher, electionResults, roll, output_dir)
    anr_mayor.stats()


if __name__ == "__main__":
    main()
