             @  `= calculo dos juros, sendo que precisa de arrays para isso S  `= Versao 0.1: 18/05/2025: feita sem muito conhecimento de Enterprise IS-BASIC 1_  `= variaveis globais e atribuicao de valores d  `("QT�  n  `(!K�  x  `("PR�    0A �  `"PA"QT� 	 �  `"PE"QT� 	 �  `!I�  "TO"QT�  � `("PA!I	"PR
!I� 	 � `("PE!I	�    @ 	�  `/!I %' `= testa os retornos das funcoes 
, ` �� 6 `8�Peso total ="PT @ `("JU�    0@ 
J ` �� T `8�Acrescimo ="AC ^ `("PC�  h `("IT�d  r `("MA�2  | `("AP"AC 
� ` �� � `8�Juros ="JU � ` '� `= calcula a somatoria dos Pesos() � `("PT�   � `!I�  "TO"QT�  `("PT"PT"PE!I	 	 `/!I  `A 9� `= calcula o acrescimo a partir dos juros e parcelas � `("AC�   � `%"JU�  $THEN`A � `%"QT� $THEN`A  `%"PR�  $THEN`A 
 ` ��  `%"PT�  $THEN`A $ `("CU�   . `!I�  "TO"QT�  8`&!K� $THEN :L`("CU"CU"PE!I	�    @"JU�    B	"PA!I	"PR	 V` 8�`("CU"CU"PE!I	�    @"JU�    B
"PA!I	"PR	 �` 	 `/!I  `%"CU�  $THEN`A $( `("AC"PT"CU�    @	
�    B 2 `A 9� `= calcula os juros a partir do acrescimo e parcelas � `("JU�   � `%"IT� $THEN`A � `%"QT� $THEN`A � `%"PC� $THEN`A  `%"PR�  $THEN`A  `%"AP�  $THEN`A  `%"MA�  $THEN`A 
" ` �� , `%"PT�  $THEN`A 6 `("MN�   @ `("JU"MA�     @ J `("MD�    ?"PC T `!T� "TO"IT ^`%"MA"MN"MD$THEN`A 
h` �� r`&"AC"AP$THEN |`("MN"JU �` �`("MA"JU �` �`("JU"MN"MA	�     @ 	� `/!T � `A   
              