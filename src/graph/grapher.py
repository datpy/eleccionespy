import pathlib

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

from adjustText import adjust_text
from ..stats import Stats


class Grapher:
    """
    Grapher defines methods to create scatter plots for different independent
    variables in the development indicators dataframe.
    """

    def __init__(self, devIndicators: pd.DataFrame, stats: Stats) -> None:
        self.devIndicators = devIndicators
        self.income = devIndicators.query("indicador == 'ECON_IMAP'")
        self.stats = stats

        style = str(pathlib.Path(__file__).parent) + "/.mplstyle"
        plt.style.use(style)

    def make_vs_income_graph(
        self,
        df: pd.DataFrame,
        y_column: str,
        title: str,
        xlab: str,
        ylab: str,
        yticksuffix: str = "",
    ):
        """
        Takes a data frame and the column to be used as the dependent variable
        and creates a plot with income as the independent variable.

        Parameters
        ----------
        df : Dataframe
            The dataframe that contains the dependent variable and the column
            by which to merge the dependent and independent variables.
        y_column: String
            The dependent variable's column name in dataframe.
        title: String
            The plot's title.
        xlab: String
            The x axis label.
        ylab: String
            The y axis label.
        yticksuffix:
            Suffix to add to the dependent variable's ticks such as "%".
        """

        income = self.income[["dep", "valor"]]
        income = income.rename(columns={"valor": "income"})
        income["income_millions"] = income["income"] / 1000000

        mergedDf = df.merge(income, on="dep")

        # Create regression plot.s
        ax = sns.regplot(
            x=mergedDf["income_millions"],
            y=mergedDf[y_column],
            ci=None,
            scatter_kws={"fc": "none", "edgecolor": "black"},
            line_kws={"color": "red"}
        )
        ax.set(xlabel=xlab, ylabel=ylab, title=title)
        ax.set_xlim(1.3, 4.5)

        # Add % suffix to y ticks.
        ticks = plt.yticks()[0]
        ylabels = [f"{y:.0f}{yticksuffix}" for y in ticks]
        plt.yticks(ticks=ticks, labels=ylabels)

        # Add labels for each point.
        texts = [
            plt.text(
                mergedDf.loc[i, "income_millions"],
                mergedDf.loc[i, y_column],
                mergedDf.loc[i, "depdes"],
            )
            for i in range(len(mergedDf.index))
        ]
        adjust_text(
            texts,
            force_points=(0.5, 0.5),
            expand_points=(1.2, 1.2)
        )

        annotation = self.stats.r_and_p_value(
            mergedDf["income_millions"],
            mergedDf[y_column]
        )
        ax.text(2.5, 30, annotation, fontsize=16, fontstyle="italic", c="blue")

        return ax.plot()
