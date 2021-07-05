import pandas as pd
import pathlib
import src as eleccionespy

ELECTION_RESULTS_FILE = "./data/resultados-1996-2018.csv"
ELECTOTRAL_ROLL_FILE = "./data/padron-1998-2018.csv"
DEV_INDICATORS_FILE = "./data/indicadores-desarrollo-dep.csv"


def main():
    election_results = pd.read_csv(ELECTION_RESULTS_FILE)
    election_results = election_results[["anio", "dep", "depdes", "dis",
                                         "disdes", "zon", "loc", "cand_desc",
                                         "siglas_lista", "votos",
                                         "total_votos"]]

    roll_df = pd.read_csv(ELECTOTRAL_ROLL_FILE)
    roll_df = roll_df[["anio", "dep", "depdes", "dis", "disdes", "total"]]
    roll_df = roll_df.rename(columns={"total": "eligible_voters"})
    roll = eleccionespy.ElectoralRoll(roll_df)

    dev_indicators_df = pd.read_csv(DEV_INDICATORS_FILE)
    dev_indicators_df = dev_indicators_df.query(
        "indicator == 'ECON_IMAP'"
        "| indicator == 'PBRZ_PTOTL'"
        "| indicator == 'PBRZ_NBI'"
        "| indicator == 'SALU_PMNV10-19'"
    )
    dev_indicators = eleccionespy.DevelopmentIndicators(dev_indicators_df)

    stats = eleccionespy.Stats()

    grapher = eleccionespy.Grapher(dev_indicators, stats)

    output_dir = pathlib.Path(__file__).parent
    output_dir = output_dir.joinpath("output/graphs").absolute()

    anr_mayor = eleccionespy.AnrMayor(
        grapher, election_results, roll, dev_indicators, output_dir)
    anr_mayor.stats()


if __name__ == "__main__":
    main()
