public func curry<A: Sendable, B: Sendable, C: Sendable>(_ function: @escaping @Sendable (A, B) -> C) -> @Sendable (A) -> @Sendable (B) -> C {
    return { @Sendable (a: A) -> @Sendable (B) -> C in
        { @Sendable (b: B) -> C in
            function(a, b)
        }
    }
}

public func curry<A: Sendable, B: Sendable, C: Sendable, D: Sendable>(_ function: @escaping @Sendable (A, B, C) -> D) -> @Sendable (A) -> @Sendable (B) -> @Sendable (C) -> D {
    return { (a: A) -> @Sendable (B) -> @Sendable (C) -> D in
      { (b: B) -> @Sendable (C) -> D in
        { (c: C) -> D in
          function(a, b, c)
        }
      }
    }
}

public func curry<A: Sendable, B: Sendable, C: Sendable, D: Sendable, E: Sendable>(_ function: @escaping @Sendable (A, B, C, D) -> E) -> @Sendable (A) -> @Sendable (B) -> @Sendable (C) -> @Sendable (D) -> E {
    return { (a: A) -> @Sendable (B) -> @Sendable (C) -> @Sendable (D) -> E in
      { (b: B) -> @Sendable (C) -> @Sendable (D) -> E in
        { (c: C) -> @Sendable (D) -> E in
          { (d: D) -> E in
            function(a, b, c, d)
          }
        }
      }
    }
}

public func curry<A: Sendable, B: Sendable, C: Sendable, D: Sendable, E: Sendable, F: Sendable>(_ function: @escaping @Sendable (A, B, C, D, E) -> F) -> @Sendable (A) -> @Sendable (B) -> @Sendable (C) -> @Sendable (D) -> @Sendable (E) -> (F) {
    return { (a: A) -> @Sendable (B) -> @Sendable (C) -> @Sendable (D) -> @Sendable (E) -> F in
      { (b: B) -> @Sendable (C) -> @Sendable (D) -> @Sendable (E) -> F in
        { (c: C) -> @Sendable (D) -> @Sendable (E) -> F in
          { (d: D) -> @Sendable (E) -> F in
            { (e: E) -> F in
              function(a, b, c, d, e)
            }
          }
        }
      }
    }
}

public func curry<A: Sendable, B: Sendable, C: Sendable, D: Sendable, E: Sendable, F: Sendable, G: Sendable>(_ function: @escaping @Sendable (A, B, C, D, E, F) -> G) -> @Sendable (A) -> @Sendable (B) -> @Sendable (C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> G {
    return { (a: A) -> @Sendable (B) -> @Sendable (C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> G in
      { (b: B) -> @Sendable (C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> G in
        { (c: C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> G in
          { (d: D) -> @Sendable (E) -> @Sendable (F) -> G in
            { (e: E) -> @Sendable (F) -> G in
              { (f: F) -> G in
                function(a, b, c, d, e, f)
              }
            }
          }
        }
      }
    }
}

public func curry<A: Sendable, B: Sendable, C: Sendable, D: Sendable, E: Sendable, F: Sendable, G: Sendable, H: Sendable>(_ function: @escaping @Sendable (A, B, C, D, E, F, G) -> H) -> @Sendable (A) -> @Sendable (B) -> @Sendable (C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> H {
    return { (a: A) -> @Sendable (B) -> @Sendable (C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> H in
      { (b: B) -> @Sendable (C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> H in
        { (c: C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> H in
          { (d: D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> H in
            { (e: E) -> @Sendable (F) -> @Sendable (G) -> H in
              { (f: F) -> @Sendable (G) -> H in
                { (g: G) -> H in
                  function(a, b, c, d, e, f, g)
                }
              }
            }
          }
        }
      }
    }
}

public func curry<A: Sendable, B: Sendable, C: Sendable, D: Sendable, E: Sendable, F: Sendable, G: Sendable, H: Sendable, I: Sendable>(_ function: @escaping @Sendable (A, B, C, D, E, F, G, H) -> I) -> @Sendable (A) -> @Sendable (B) -> @Sendable (C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> I {
    return { (a: A) -> @Sendable (B) -> @Sendable (C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> I in
      { (b: B) -> @Sendable (C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> I in
        { (c: C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> I in
          { (d: D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> I in
            { (e: E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> I in
              { (f: F) -> @Sendable (G) -> @Sendable (H) -> I in
                { (g: G) -> @Sendable (H) -> I in
                  { (h: H) -> I in
                    function(a, b, c, d, e, f, g, h)
                  }
                }
              }
            }
          }
        }
      }
    }
}

public func curry<A: Sendable, B: Sendable, C: Sendable, D: Sendable, E: Sendable, F: Sendable, G: Sendable, H: Sendable, I: Sendable, J: Sendable>(_ function: @escaping @Sendable (A, B, C, D, E, F, G, H, I) -> J) -> @Sendable (A) -> @Sendable (B) -> @Sendable (C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> J {
    return { (a: A) -> @Sendable (B) -> @Sendable (C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> J in
      { (b: B) -> @Sendable (C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> J in
        { (c: C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> J in
          { (d: D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> J in
            { (e: E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> J in
              { (f: F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> J in
                { (g: G) -> @Sendable (H) -> @Sendable (I) -> J in
                  { (h: H) -> @Sendable (I) -> J in
                    { (i: I) -> J in
                      function(a, b, c, d, e, f, g, h, i)
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
}

public func curry<A: Sendable, B: Sendable, C: Sendable, D: Sendable, E: Sendable, F: Sendable, G: Sendable, H: Sendable, I: Sendable, J: Sendable, K: Sendable>(_ function: @escaping @Sendable (A, B, C, D, E, F, G, H, I, J) -> K) -> @Sendable (A) -> @Sendable (B) -> @Sendable (C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> @Sendable (J) -> K {
    return { (a: A) -> @Sendable (B) -> @Sendable (C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> @Sendable (J) -> K in
      { (b: B) -> @Sendable (C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> @Sendable (J) -> K in
        { (c: C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> @Sendable (J) -> K in
          { (d: D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> @Sendable (J) -> K in
            { (e: E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> @Sendable (J) -> K in
              { (f: F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> @Sendable (J) -> K in
                { (g: G) -> @Sendable (H) -> @Sendable (I) -> @Sendable (J) -> K in
                  { (h: H) -> @Sendable (I) -> @Sendable (J) -> K in
                    { (i: I) -> @Sendable (J) -> K in
                      { (j: J) -> K in
                        function(a, b, c, d, e, f, g, h, i, j)
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
}

public func curry<A: Sendable, B: Sendable, C: Sendable, D: Sendable, E: Sendable, F: Sendable, G: Sendable, H: Sendable, I: Sendable, J: Sendable, K: Sendable, L: Sendable>(_ function: @escaping @Sendable (A, B, C, D, E, F, G, H, I, J, K) -> L) -> @Sendable (A) -> @Sendable (B) -> @Sendable (C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> @Sendable (J) -> @Sendable (K) -> L {
    return { (a: A) -> @Sendable (B) -> @Sendable (C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> @Sendable (J) -> @Sendable (K) -> L in
      { (b: B) -> @Sendable (C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> @Sendable (J) -> @Sendable (K) -> L in
        { (c: C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> @Sendable (J) -> @Sendable (K) -> L in
          { (d: D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> @Sendable (J) -> @Sendable (K) -> L in
            { (e: E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> @Sendable (J) -> @Sendable (K) -> L in
              { (f: F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> @Sendable (J) -> @Sendable (K) -> L in
                { (g: G) -> @Sendable (H) -> @Sendable (I) -> @Sendable (J) -> @Sendable (K) -> L in
                  { (h: H) -> @Sendable (I) -> @Sendable (J) -> @Sendable (K) -> L in
                    { (i: I) -> @Sendable (J) -> @Sendable (K) -> L in
                      { (j: J) -> @Sendable (K) -> L in
                        { (k: K) -> L in
                          function(a, b, c, d, e, f, g, h, i, j, k)
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
}

public func curry<A: Sendable, B: Sendable, C: Sendable, D: Sendable, E: Sendable, F: Sendable, G: Sendable, H: Sendable, I: Sendable, J: Sendable, K: Sendable, L: Sendable, M: Sendable>(_ function: @escaping @Sendable (A, B, C, D, E, F, G, H, I, J, K, L) -> M) -> @Sendable (A) -> @Sendable (B) -> @Sendable (C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> @Sendable (J) -> @Sendable (K) -> @Sendable (L) -> M {
    return { (a: A) -> @Sendable (B) -> @Sendable (C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> @Sendable (J) -> @Sendable (K) -> @Sendable (L) -> M in
      { (b: B) -> @Sendable (C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> @Sendable (J) -> @Sendable (K) -> @Sendable (L) -> M in
        { (c: C) -> @Sendable (D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> @Sendable (J) -> @Sendable (K) -> @Sendable (L) -> M in
          { (d: D) -> @Sendable (E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> @Sendable (J) -> @Sendable (K) -> @Sendable (L) -> M in
            { (e: E) -> @Sendable (F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> @Sendable (J) -> @Sendable (K) -> @Sendable (L) -> M in
              { (f: F) -> @Sendable (G) -> @Sendable (H) -> @Sendable (I) -> @Sendable (J) -> @Sendable (K) -> @Sendable (L) -> M in
                { (g: G) -> @Sendable (H) -> @Sendable (I) -> @Sendable (J) -> @Sendable (K) -> @Sendable (L) -> M in
                  { (h: H) -> @Sendable (I) -> @Sendable (J) -> @Sendable (K) -> @Sendable (L) -> M in
                    { (i: I) -> @Sendable (J) -> @Sendable (K) -> @Sendable (L) -> M in
                      { (j: J) -> @Sendable (K) -> @Sendable (L) -> M in
                        { (k: K) -> @Sendable (L) -> M in
                          { (l: L) -> M in
                            function(a, b, c, d, e, f, g, h, i, j, k, l)
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
}

public func uncurry<A: Sendable, B: Sendable, C: Sendable>(_ f: @escaping @Sendable (A) -> @Sendable (B) -> C) -> @Sendable (A, B) -> C {
    return { a, b in
        f(a)(b)
    }
}
