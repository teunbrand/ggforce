#' Position scales for units data
#'
#' These are the default scales for the units class. These will
#' usually be added automatically. To override manually, use
#' \code{scale_*_unit}.
#'
#' @inheritParams ggplot2::continuous_scale
#' @inheritParams ggplot2::scale_x_continuous
#' @param unit A unit specification to use for the axis. If given, the values
#' will be converted to this unit before plotting. An error will be thrown if
#' the specified unit is incompatible with the unit of the data.
#'
#' @examples
#' mtcars$consumption <- mtcars$mpg * with(ud_units, mi/gallon)
#' mtcars$power <- mtcars$hp * with(ud_units, hp)
#'
#' # Use units encoded into the data
#' ggplot(mtcars) +
#'     geom_point(aes(power, consumption))
#'
#' # Convert units on the fly during plotting
#' ggplot(mtcars) +
#'     geom_point(aes(power, consumption)) +
#'     scale_x_unit(unit = 'W') +
#'     scale_y_unit(unit = 'km/l')
#'
#' # Resolve units when transforming data
#' ggplot(mtcars) +
#'     geom_point(aes(power, 1/consumption))
#'
#' @name scale_unit
#' @aliases NULL
NULL

#' @rdname scale_unit
#' @export
#' @importFrom scales censor
#' @importFrom units make_unit
scale_x_unit <- function(name = waiver(), breaks = waiver(), unit = NULL,
                          minor_breaks = waiver(), labels = waiver(),
                          limits = NULL, expand = waiver(), oob = censor,
                          na.value = NA_real_, trans = "identity",
                          position = "bottom", sec.axis = waiver()) {
    sc <- continuous_scale(
        c("x", "xmin", "xmax", "xend", "xintercept", "xmin_final", "xmax_final", "xlower", "xmiddle", "xupper"),
        "position_c", identity, name = name, breaks = breaks,
        minor_breaks = minor_breaks, labels = labels, limits = limits,
        expand = expand, oob = oob, na.value = na.value, trans = trans,
        guide = "none", position = position, super = ScaleContinuousPositionUnit
    )
    sc$unit <- switch(
        class(unit),
        symbolic_units = ,
        'NULL' = unit,
        character = make_unit(unit),
        units = units(unit),
        stop('unit must either be NULL or of class `units` or `symbolic_units`', call. = FALSE)
    )
    if (!inherits(sec.axis, 'waiver')) {
        if (is.formula(sec.axis)) sec.axis <- sec_axis(sec.axis)
        if (!is.sec_axis(sec.axis)) stop("Secondary axes must be specified using 'sec_axis()'")
        sc$secondary.axis <- sec.axis
    }
    sc
}
#' @rdname scale_unit
#' @export
#' @importFrom scales censor
#' @importFrom units make_unit
scale_y_unit <- function(name = waiver(), breaks = waiver(), unit = NULL,
                          minor_breaks = waiver(), labels = waiver(),
                          limits = NULL, expand = waiver(), oob = censor,
                          na.value = NA_real_, trans = "identity",
                          position = "left", sec.axis = waiver()) {
    sc <- continuous_scale(
        c("y", "ymin", "ymax", "yend", "yintercept", "ymin_final", "ymax_final", "lower", "middle", "upper"),
        "position_c", identity, name = name, breaks = breaks,
        minor_breaks = minor_breaks, labels = labels, limits = limits,
        expand = expand, oob = oob, na.value = na.value, trans = trans,
        guide = "none", position = position, super = ScaleContinuousPositionUnit
    )
    sc$unit <- switch(
        class(unit),
        symbolic_units = ,
        'NULL' = unit,
        character = make_unit(unit),
        units = units(unit),
        stop('unit must either be NULL or of class `units` or `symbolic_units`', call. = FALSE)
    )
    if (!inherits(sec.axis, 'waiver')) {
        if (is.formula(sec.axis)) sec.axis <- sec_axis(sec.axis)
        if (!is.sec_axis(sec.axis)) stop("Secondary axes must be specified using 'sec_axis()'")
        sc$secondary.axis <- sec.axis
    }
    sc
}
#' @rdname ggforce-extensions
#' @format NULL
#' @usage NULL
#' @importFrom units as.units make_unit_label
#' @export
ScaleContinuousPositionUnit <- ggproto('ScaleContinuousPositionUnit', ScaleContinuousPosition,
    unit = NULL,

    train = function(self, x) {
        if (length(x) == 0) return()
        if (!is.null(self$unit)) {
            units(x) <- as.units(1, self$unit)
        }
        self$range$train(x)
    },
    map = function(self, x, limits = self$get_limits()) {
        if (inherits(x, 'units')) {
            if (is.null(self$unit)) {
                self$unit <- units(x)
            } else {
                units(x) <- as.units(1, self$unit)
            }
        }
        x <- as.numeric(x)
        ggproto_parent(ScaleContinuousPosition, self)$map(x, limits)
    },
    make_title = function(self, title) {
        make_unit_label(title, as.units(1, self$unit))
    }
)
#' @rdname scale_unit
#' @format NULL
#' @usage NULL
#' @export
scale_type.units <- function(x) c('unit', 'continuous')