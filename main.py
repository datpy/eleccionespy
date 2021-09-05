import pandas as pd
import pathlib
import src as eleccionespy

ELECTION_RESULTS_FILE = "./data/resultados-1996-2018.csv"
TURNOUT_2015_FILE = "./data/2015-districtwise-turnout.csv"
DEV_INDICATORS_FILE = "./data/indicadores-desarrollo-dep.csv"


def main():
    election_results = pd.read_csv(ELECTION_RESULTS_FILE)
    election_results = election_results[["anio", "dep", "depdes", "dis",
                                         "disdes", "zon", "loc", "cand_desc",
                                         "siglas_lista", "votos",
                                         "total_votos"]]

    turnout = pd.read_csv(TURNOUT_2015_FILE)
    turnout = turnout[["cand_desc", "dep", "depdes", "dis",
                       "disdes", "electores", "total"]]
    turnout = turnout.rename(columns={
        "electores": "eligible_voters", "total": "total_votes"})

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
        grapher, election_results, turnout, dev_indicators, output_dir)
    anr_mayor.stats()


if __name__ == "__main__":
    main()
