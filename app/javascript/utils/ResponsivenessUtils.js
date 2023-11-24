// Where breakpoint in ["xs", "sm", "md", "lg", "xl", "xxl"]
export function bootstrapBreakpoint(breakpoint) {
  return parseFloat(getComputedStyle(document.body).getPropertyValue(`--bs-breakpoint-${breakpoint}`));
}

export function isMediaBreakpointUp(breakpoint) {
  const currentWidth = parseFloat(getComputedStyle(document.body).width);
  const breakpointWidth = bootstrapBreakpoint(breakpoint);

  return currentWidth >= breakpointWidth;
}

export function isMediaBreakpointDown(breakpoint) {
  const currentWidth = parseFloat(getComputedStyle(document.body).width);
  const breakpointWidth = bootstrapBreakpoint(breakpoint);

  return currentWidth < breakpointWidth;
}
