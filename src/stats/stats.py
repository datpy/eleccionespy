from scipy import stats


class Stats:
    """
    The class Stats defines several statistics calculation functions such as
    linear regression and p values.
    """

    def r_and_p_value(self, x, y) -> str:
        _, _, r_value, p_value, _ = stats.linregress(x, y)

        return f"R = {r_value:.2f}, p = {p_value:.2e}"
