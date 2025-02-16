namespace TesteJuros
{
    public partial class MainPage : ContentPage
    {
        public MainPage()
        {
            InitializeComponent();
        }

        private void OnTesteClicked(object sender, EventArgs e)
        {
            JurosMAUI juros = new(3, true, 30.0);

            for(int indice = 0; indice < juros.Quantidade; indice++)
            {
                juros.Pagamentos[indice] = 30.0 * (indice + 1.0);
                juros.Pesos[indice] = 1.0;
            }

            double pesoTotal = juros.getPesoTotal();
            double acrescimoCalculado = juros.jurosParaAcrescimo(3.0);
            double jurosCalculalado = juros.acrescimoParaJuros(acrescimoCalculado);
            BotaoTeste.Text = $"Peso total = {pesoTotal}, acréscimo = {acrescimoCalculado}, juros = {jurosCalculalado}";
        }
    }

}
