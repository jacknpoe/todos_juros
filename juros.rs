/// "Classe" Juros para os cálculos entre acréscimo e juros
pub struct Juros {
    pub quantidade: usize,
    pub composto: bool,
    pub periodo: f64,
    pub pagamentos: Vec<f64>,
    pub pesos: Vec<f64>,
}

/// Métodos da "classe" Juros
impl Juros {
    /// Cria um "objeto" Juros e atribui valores para os "atributos"
    pub fn novo(quantidade: usize, composto: bool, periodo: f64, pagamentos: Vec<f64>, pesos: Vec<f64>) -> Self {
        Self {
            quantidade,
            composto,
            periodo,
            pagamentos,
            pesos,
        }
    }

    /// Calcula o peso total, somando todos os valores do array pesos
    pub fn get_peso_total(&self) -> f64 {
        let mut acumulador: f64 = 0.0;
        for indice in 0..self.quantidade {
            acumulador += self.pesos[indice];
        }
        acumulador
    }

    /// Calcula o total do acréscimo a partir dos juros e dos dados no "objeto"
    pub fn juros_para_acrescimo(&self, juros: f64) -> f64 {
        if juros <= 0.0 || self.quantidade <= 0 || self.periodo <= 0.0 {
            return 0.0;
        }
        let peso_total: f64 = self.get_peso_total();
        if peso_total <= 0.0 {
            return 0.0;
        } else {
            let mut acumulador: f64 = 0.0;
            let mut so_zero: bool = true;

            for indice in 0..self.quantidade {
                if self.pagamentos[indice] > 0.0 && self.pesos[indice] > 0.0 {
                    so_zero = false;
                }
                if self.composto {
                    acumulador += self.pesos[indice] / (1.0 + juros / 100.0).powf(self.pagamentos[indice] / self.periodo);
                } else {
                    acumulador += self.pesos[indice] / (1.0 + juros / 100.0 * self.pagamentos[indice] / self.periodo);
                }
            }

            if so_zero {
                return 0.0;
            } else {
                return (peso_total / acumulador - 1.0) * 100.0;
            }
        }
    }

    /// Calcula o total dos juros a partir do acréscimo e dos dados no "objeto"
    pub fn acrescimo_para_juros (&self, acrescimo: f64, precisao: f64, max_iteracoes: usize, maximo_juros: f64) -> f64 {
        if max_iteracoes < 1 || self.quantidade <= 0 || precisao < 1.0 || self.periodo <= 0.0 || acrescimo <= 0.0 || maximo_juros <= 0.0 {
            return 0.0;
        }
        let mut min_juros: f64 = 0.0;
        let mut med_juros: f64 = maximo_juros / 2.0;
        let mut max_juros: f64 = maximo_juros;
        let min_diferenca: f64 = 0.1_f64.powf(precisao);
        let peso_total: f64 = self.get_peso_total();
        if peso_total <= 0.0 {
            return 0.0;
        }

        for _indice in 0..max_iteracoes {
            med_juros = (min_juros + max_juros) / 2.0;
            if (max_juros - min_juros) < min_diferenca {
                return med_juros;
            }
            if self.juros_para_acrescimo(med_juros) <= acrescimo {
                min_juros = med_juros;
            } else {
                max_juros = med_juros;
            }
        }

        return med_juros;
    }
}