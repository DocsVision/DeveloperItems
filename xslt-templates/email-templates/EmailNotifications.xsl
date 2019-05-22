<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output	encoding="utf-8"
				  method="html"
				  indent="yes"
				  doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
				  doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

  <!--отображаемое имя из справочника сотрудников-->
  <xsl:template name="getdisplayname">
    <xsl:param name="lastname" select="."/>
    <xsl:param name="firstname" select="."/>
    <xsl:param name="middlename" select="."/>
    <xsl:param name="displaystring" select="."/>
    <xsl:if test="string-length($displaystring)!=0">
      <xsl:value-of select="$displaystring"/>
    </xsl:if>
    <xsl:if test="string-length($displaystring)=0">
      <xsl:value-of select="$lastname"/>
      <xsl:if test="string-length($lastname)!=0">
        <xsl:text></xsl:text>
      </xsl:if>
      <xsl:value-of select="$firstname"/>
      <xsl:if test="string-length($firstname)!=0">
        <xsl:text></xsl:text>
      </xsl:if>
      <xsl:value-of select="$middlename"/>
    </xsl:if>
  </xsl:template>

  <!-- сотрудник -->
  <xsl:template name="getemployeedisplayname">
    <xsl:param name="employeerow" select="."/>
    <xsl:call-template name="getdisplayname">
      <xsl:with-param name="lastname" select="$employeerow/@LastName"/>
      <xsl:with-param name="firstname" select="$employeerow/@FirstName"/>
      <xsl:with-param name="middlename" select="$employeerow/@MiddleName"/>
      <xsl:with-param name="displaystring" select="$employeerow/@DisplayString"/>
    </xsl:call-template>
  </xsl:template>

  <!--Конвертация даты в желаемый формат-->
  <xsl:template name="convertdate" match="text()" mode="replace">
    <xsl:param name="str" select="."/>
    <xsl:if test="string-length($str)>0">
      <xsl:copy-of select="substring($str, 9, 2)"/>
      <xsl:text>.</xsl:text>
      <xsl:copy-of select="substring($str, 6, 2)"/>
      <xsl:text>.</xsl:text>
      <xsl:copy-of select="substring($str, 1, 4)"/>
      <xsl:text> </xsl:text>
      <xsl:copy-of select="substring($str, 12, 2)"/>
      <xsl:text>:</xsl:text>
      <xsl:copy-of select="substring($str, 15, 2)"/>
    </xsl:if>
  </xsl:template>

  <!--Для сохранения переносов строки в тексте-->
  <xsl:template name="LFsToBRs">
    <xsl:param name="input" />
    <xsl:choose>
      <xsl:when test="contains($input, '&#10;')">
        <xsl:value-of select="substring-before($input, '&#10;')" />
        <br/>
        <xsl:call-template name="LFsToBRs">
          <xsl:with-param name="input" select="substring-after($input, '&#10;')" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$input" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Комментарий последнего делегата-->
  <xsl:template name="delegatecomment">
    <xsl:for-each select="//*/DelegatesRow">
      <xsl:sort select="@Date" order="descending"/>
      <xsl:if test="position() = 1">
        <xsl:value-of select="@Comment"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- письмо -->
  <xsl:template match="/">
    <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
    <html>
      <Head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <title>
          <xsl:value-of select="//Title/@Description"/>
        </title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <style type="text/css" media="all">
          <xsl:if test="//Title/@MessageType=0">
            .bg {
            background: #133c60;
            height: 100%;
            }
          </xsl:if>
          <xsl:if test="//Title/@MessageType=1">
            .bg {
            background: #bbd02d;
            height: 100%;
            }
          </xsl:if>
          <xsl:if test="//Title/@MessageType=2">
            .bg {
            background: #f18a00;
            height: 100%;
            }
          </xsl:if>
          <xsl:if test="//Title/@MessageType=3">
            .bg {
            background: #173845;
            height: 100%;
            }
          </xsl:if>
        </style>
      </Head>

      <body style="margin:0; padding:0">
        <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" class="bg" style="border-collapse:collapse;">
          <tr>
            <td></td>
            <td width ="600">
              <table align="center" width="100%" border="0" cellpadding="0" cellspacing="0" style="border-collapse:collapse;">
                <tr>
                  <td style="width: 16px;"></td>
                  <td height="90" align="center">
                    <xsl:if test="//Title/@MessageType=0">
                      <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAMgAAAAqCAIAAAB5toNAAAAABGdBTUEAALGPC/xhBQAAAAlwSFlzAAALEgAACxIB0t1+/AAAABh0RVh0U29mdHdhcmUAcGFpbnQubmV0IDQuMS42/U4J6AAABuxJREFUeF7tmT+LnUUUxv0O1hZWVqIfIGIlWqUwNoLCVoJ/OqsN2KnRLlslICk3ok0aVwhWurUiNoJdGhsbEazXH/cMDydnZt6Zu/e+3iU5h4fl5sy/c878Zt733jzz7LWjVGrvSrBSqyjBSq2iBCu1ihKs1CpKsFKrKMFKraIEK7WKDg/W9Y9u3T87RzdPTkPTEyyy/vLeg5ff+jj4txLDmeTVo0+C/yro8GB9+NlXFxs7/+X30PSkCiD2kvJvfzxikr//+ff5N94PTQdXgnUAwcFeUma4zZNgNfQUgoXePT7Z16OQp2rwXwUlWKlVlGClVtH/ChZXN/c28u8E82A1h0+KIXx7Yuzkd6hd1tqLFPCOj0s0nzt7Ydo96wZYL1x/+73PXw/OXURpvrj3gC8vBpDZoz//un92TtMQLCpCzzCcL0QMDD1rUSCWZuYybGNMZUuHziamtW9bMkJlktD/5skpfvTdjz97f9Cdbx5aN16G5CQjczZTpjUETM9mwDYJeulGI5dL5F46XVwwIWEQPMOpBn/53BvVVBusH359cV9sHd8+DUx4oyhsjH1uVpl8rLVpDF84hRSCDqVry6h7GIKntFUW1mLy0tD/UoZfuftdYc/MyZxymhYCYKrwU19p2HDg/YhQt80dlbbNuS2fHjegnLzMumDthS1fJrjh1NpN+/X353XaNVikUdo2rZSVsfxlePFujH0KAxEbqU3lw91vH9rSxOCX9vtNqznp3ww1cEBI5u/9tKsJQ2o9sASrD5gPPgC/r+bEAlh85SwNi7lTXj8KlQZnDPdDMJibYWsJrB3ZUlmxuvQUkYRL88ZC9QUludXoMFynig6eD5PKQbe6lXgYRYTeKVBCf/5peAW/+AiRS5qQnfb+HlgqSOiPYKJO0zpjHiz6KHfCriEgd2vFmNY3Fe/GmMSX3SpmTTxG5O9pANYubCm9EL2XnoOY3x6qU7ydCwlRMrEVDp9qRwy941X7LWD+Br+pOY9q3UTfmuoJe2AJRO+UAlXIOmMeLF3zCy9/qg/x+7zMiRFYvZzCxobfA8ZgXY4tXVe9fTKRlfbGg6WzW1/XXko1FIhFzR/upGVp1Aefzo7izNiQ+vBo8+qmHlh6xDdfgGpZZ0xg+QNZk+EliH145sF6dWuOamoKLLQtW7qKqG9oClI1PVi6iuqbIEg06PHBYTIPtKnbjEQJBtDDpRE0W/96LQW2cPQDWP7lgWoMT0Xp6sDS25UvZlNay/c0D9a7kDTq7Kel78JoFiy0FVtCe7g9OtnNDMNraS1xKYLnixsEJQLajI0fEtbMVOg0b9weWCi8d8IrR7RHWOnkqqSzwTzq1pTuNh+DebBe2edruwVYaJ4tndchWMtHR56eBJYu5+aE82K4gpfh6T1Zmgzx2ZzN9BfAQgQQ+MboWb/Rl7YWWMNHlcDyd615sB5YinzPYKFJtvQo7J02SbXwsZKtOYc3Vv3M1alie9RtW1FBkPWEEVLvAWHR8lfveTawyQ1aBsvEWlTGB4AFtorXVUnXf/Om9FIMvkrmwQ4AFpphS1f68E4mROvpY5Vz+Iqm0pOzefTeg/k3+suJabVEr5o6GxatyO4dqhmwJAhTNfztgsyJiQPNHHrWEoL+bck82GHAQkO2fIYLX090IWM+VqVN6Rfg0FMv7JB2YvhEmBEB2J3U40AdLAVdosOn5wxYJmXkt9w8mJyKBKsfnV4sbd08/ebBDgYWGrKlWnDZNuGg7koP87HSX029n+P88HA3KH+s9/w6vn0aNp6ePRTspWeBA8HEJPZh4WHUA4vVezRofl9J82CeA12fC0daPz6HAMyJHRIstMwWWen0kAAx+Vb+KSzMQqweDsoaasQGaHJafZNJL/V0C89T9sb+C5IANC1A2IQUPRwDENzMNMWK3rtDvl7q7PeVSKwgrBKS9ZN7vzmxwIFiYMJw5JhZjGJhoeI9OFhomS3tlhl5khWyCgarY9XhM6NeNtzPibN5HeJUfTGGMD97Fpy6z/TwxdQZ+VDDNgQxpPR7nJhaTbBCrRSADzhQUrwVB2LUjM/N3MNsqLRdBbDQ8N7yFQ9GttrRZqxk4mvkjdIMX6ECmt5YLoDCLbiw1vIrC/Jo1nvm1QQLBSC8EUC4d1Fpa3HAuQo/iXkjd50or9J8RcBCM+/y5Ek0FA5x67Dltq+2neb0Q7zow6PND6fKzYuqFqvQmbGcV8byl0iIJ3STYIL5rbOtRagza9HH7hgUkA2ilTlRzQoKyfJBtQqySVAvvG1zp6epNyE4Wofh/0M3wHrutXdeOXpzW4VJUk+5GmClUrsrwUqtogQrtYoSrNQqSrBSqyjBSq2iBCu1ihKs1CpKsFIr6NrRf3zHizU3mv8oAAAAAElFTkSuQmCC" alt="Docsvision logo" width="200" height="42" />
                    </xsl:if>
                    <xsl:if test="//Title/@MessageType=1">
                      <img src="data:image/png;base64,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" alt="Docsvision logo" width="200" height="42" />
                    </xsl:if>
                    <xsl:if test="//Title/@MessageType=2">
                      <img src="data:image/png;base64,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" alt="Docsvision logo" width="200" height="42" />
                    </xsl:if>
                    <xsl:if test="//Title/@MessageType=3">
                      <img src="data:image/png;base64,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" alt="Docsvision logo" width="200" height="42" />
                    </xsl:if>
                  </td>
                  <td style="width: 16px;"></td>
                </tr>
                <tr>
                  <td style="width: 16px;"></td>
                  <td>
                    <table align="center" width="100%" border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse;width: 600px;max-width: 600px; background: #ffffff">

                      <!-- информация о замещении -->
                      <xsl:if test="//Employee/Hints/Deputy/@Employee">
                        <tr>
                          <td height="50" style="text-align: center;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 18px;padding: 3px 13px 3px 13px;background: #ffdd80;color: #382900;">
                            ЗАМЕЩЕНИЕ
                            <xsl:value-of select="//Employee/Hints/Deputy/@Employee"/>
                          </td>
                        </tr>
                      </xsl:if>

                      <!-- состояние -->
                      <xsl:if test="//Title/@MessageType=0">
                        <tr>
                          <td height="50">
                            <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse; ">
                              <tr>
                                <td style="font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 13px;padding: 5px 13px 5px 13px;background: #06a5ff;color: #ffffff ;text-align: center;white-space: nowrap;">
                                  <xsl:value-of select="//SendInfo/@StateName"/>
                                </td>
                                <td style="width: 40%;"></td>
                                <td align="right" style="padding-right: 10px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 13px;text-align: right;white-space: nowrap;">
                                  <xsl:value-of select="//SendInfo/@Date"/>
                                </td>
                              </tr>
                            </table>
                          </td>
                        </tr>
                      </xsl:if>
                      <xsl:if test="//Title/@MessageType=1">
                        <tr>
                          <td height="50">
                            <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse; ">
                              <tr>
                                <td style="font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 13px;padding: 5px 13px 5px 13px;background: #258023;color: #ffffff ;text-align: center;white-space: nowrap;">
                                  <xsl:value-of select="//SendInfo/@StateName"/>
                                </td>
                                <td style="width: 40%;"></td>
                                <td align="right" style="padding-right: 10px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 13px;text-align: right;white-space: nowrap;">
                                  <xsl:value-of select="//SendInfo/@Date"/>
                                </td>
                              </tr>
                            </table>
                          </td>
                        </tr>
                      </xsl:if>
                      <xsl:if test="//Title/@MessageType=2">
                        <tr>
                          <td height="50">
                            <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse; ">
                              <tr>
                                <td style="font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 13px;padding: 5px 13px 5px 13px;background: #c50000;color: #ffffff ;text-align: center;white-space: nowrap;">
                                  Ошибка
                                </td>
                                <td style="width: 40%;"></td>
                                <td align="right" style="padding-right: 10px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 13px;text-align: right;white-space: nowrap;">
                                  <xsl:value-of select="//SendInfo/@Date"/>
                                </td>
                              </tr>
                            </table>
                          </td>
                        </tr>
                      </xsl:if>
                      <xsl:if test="//Title/@MessageType=3">
                        <tr>
                          <td height="50">
                            <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse; ">
                              <tr>
                                <td style="font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 13px;padding: 5px 13px 5px 13px;background: #C50000;color: #ffffff ;text-align: center;white-space: nowrap;">
                                  <xsl:value-of select="//SendInfo/@StateName"/>
                                </td>
                                <td style="width: 40%;"></td>
                                <td align="right" style="padding-right: 10px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 13px;text-align: right;white-space: nowrap;">
                                  <xsl:value-of select="//SendInfo/@Date"/>
                                </td>
                              </tr>
                            </table>
                          </td>
                        </tr>
                      </xsl:if>

                      <!-- описание -->
                      <tr>
                        <td height="50" style="font-size: 20px;text-align: center;font-weight: bold;height: 50px;font-family: Roboto, Arial, Helvetica, sans-serif;">
                          <xsl:value-of select="//Title/@Description"/>
                        </td>
                      </tr>

                      <!-- картинка -->
                      <tr>
                        <td align="center">
                          <xsl:if test="//Title/@MessageType=0">
                            <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAKQAAACDCAYAAAADHLDPAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAABVZSURBVHgB7V1LbFzXef7O5UPRg9TDMmlZpiW/UklFLAQorAJGm0UDBEjRNi26awOjWXRTddEus2jRLNp02dYF7F3SbhKgQJ1F0bgIGglFU8tIVCdKokiGHpRIS6RIihy+hpy59+T853HPOfdePmbmznA4c77gel73Xjr0x+///+//zxnGBRDQdlTFb/m7izF+/HAJf/36CQQUI0JA2zG5wfHO4zquryT47ycb+Icb8wgoBgsK2T6QKl5divGD5QSJeB6LX/V6LcG//M89XP/DV3FmZAgBPoJCtgmPa8A7M3VJxliSEZKUgwMRjhwexp9cmUJAHoGQbcAHIjS/Ixi5UOOoJ4KMgomkjuo58NKzR3D1k9UQugsQCFkiRM2Cbz6p4z+fxkoVBfnqnMvnkoz0KI7njh6U5//lDx7hx/NVBFgEQpYEqYoiRN8ViaPJF4mMiSEjkTPh8hgYsL/2P3h/EosbMQIUAiFbBBUu356PpaWzFnOpgIp4ioTy4FwfKo9MEnv9/eUa/ub6LAIUAiFbwH1h57wrVPHmWpIqoMoXDRGRhuuUoOL18uKCd59//Mk8rj5aRUAgZFMgVXxfKOI3RL64UFeqaIhY94ioQnRilFEbbAuPHgMb6949v/L9qRC6EQjZMMjOIVX8vxXlLdZjpYp1TcJYkzDOFDMUpRkTh3ic/PhO7r4Uur9yZRr9jkDIBkCFy7szNTyt8ZR8pnKW1TSRT1Au5swJ0RzUe2DyDhwrlQoeTQniDeZN8e/cr/S9FRQIuQsYO4cKl8SQL3ZUURYqLA3PRiHpOROyKA9xn0g8Pn4oyDgwqI4CfO2Hs5gUatmvCITcAUoV67hXdciWQOeNtpCxfqOtpk2Ilo/6uHH9I+D4+JY/b3Ez7usuTiDkFjB2zvupncO9EB2nOaNTyGiCihgt1ZCQklIcy0sVzM/OgR0d2/Zn93MXJxCyAKmds56k1XGqitz6i0YNrc2jymgbomEfxXH7pzeBAwe3VUiDfu3iBEI6MDOLZOc8rdsQXXcsHVtBc6d4oXOVKkaajK4yQj/e+pkg5MjuZyH7sYsTCKkxqVXxmsgZOS9QQKOU8mA6h0xSb9GEaKOGkpjMvv5EFDPLS8tgz5ze9b9TP3ZxAiEFrlR8VUwtHR2mjQqmBU2sHhMwXaxo8kU6b5T/5J5SSnWkcD3S2LR4v3Vx+pqQxs65UhGqCGhLB57RnTidl1QpIesWG45NeCa/kdnX8jMotZx+MNUwGQ36qYvTt4Q0ds79DfXaWji2eKHXNa2MNacXLaM04zYkw9o79Av1KmxxEBkbDdcu+qmL03eENKpIds56rIoRG5KR2jtpy0/ki6SIZqSMYFTPIK+KXBJVR3Dc/Glz4dpFv3Rx+oqQt6pGFbkK0bBVdD1n71ijm3JGOl8pIbd2DvIK6Znh4n8D4sm9j++2REaDfuji9AUhjZ3zrbkY1USRK078EbHYtASp5ZeZZVTUQlrAAMhZOyzjOZr3fn7jJjaqG2BjZ9Eq+qGL0/OEdO0cAhGvFhtVVF5inGQMb8fmMfaNUkaW5oi2ulbPCZ7vqEl59/YdFa4PjaAM9HoXp6cJaWYWF+taFXUFnciJHFPIJCo8J7BGty5cfAXMG95MWjs8zSlTYupzlisV3KFwfWznzkwj6OUuTk8SkgqXd2frspImYpkQrYxuVtDys0MSZnUBA0/vZ3JDpCGbFw5OGEM8UqdialKFVzZ2BmWjV7s4PUdIY+c83uTWW3QtnYR709x17k95g5s8kKlKOYJXxBgyGtKBu2ppPlctRMofZag+cBBlo1e7OD1DSGnnzKnpnKqeS8wOQdQzqmjzRjVEG0lvUU3rEAzhzPNcCM8Q1tpBHJWlCqYeCO+wSe9xN+jFLk5PEPJWleuZRblQIPUM3dV+7kRO7KhlopNFlSPq4QgddgnexA60MmqmGmvHzSENMR8+UEY2Kzl/zKLXujj7mpBmsdW35upSFSErY+5VzG4HxuweYZYcJNpcdPNBwM0HnfwRWjGZJaUboukxAkvzyP//8CPlPbYhXLvotS7OviWksXM+0HaOqaLt1iVIyZeY6RyHqOBWCRnPmNrwX5uxMkNGQCujGTfTJIQ+n8L17OyTpluFjaKXujj7kpDfdewcgruOpc5t248CmVJFG6ZdVYyYfe53WCwRTcFip3fsWFnEbDHjkvg6qSNhpHP7QPZKF2dfEVIuQZ21JjchcUbF3Okcl4RxwVLUPOlsrhh54dhXSreaBpAzxen4mMzwDoRrF73Sxdk3hKTQTEMRZOcQiBbpjhDcMbq9PrT+HHB60Vkl5Hl1dAsUZ3LH2kG6AIK1h8z5VMwstTDZ0wp6oYsziC4H2TnfeRrjftXmilzmhUlKwkSrnxqataHZVNvuZE6aB2byRfmWVktVoDhkdE5O800YFfXvc/CTu/jC6UN47Y2XgeHOKaTBnYV1zK1uYr+iqwn50WqC95cSVUFDkTHR1bIZCUscRbSv1aM3RIuCajr73MkHwZxrWf4ecM5xCXq+/hS/efEsLl08hb3CfCBkuSA7572FGLfWba5oui4u+UzOKNUxo5YqRisrplAN4ZMr0m+kuaN7HcsT2zyPHHUdXpjBwPoqXjh3HgHNoesISbOKFKJNBU0oUsI4JaK/mVOiiejuGOEqXVYBfYIpItr3nPXV5j2OTFWt3qRrPyXCNWHs1PMIaA5dQ0hSxStLsVdBmxCt8kPdDoQN23GGiGZCB2CZAsaQJqN2TJ3pm9zmaq2SyOaZejFX2l5Uj1G9hqHZKYw/9zyGhsJm9s2iKwhJds635+ueKqoJHe7lhJaAPF1eYBSSUKSGSgm5955XQXNXFV0C+mS0oV1fkylshmcfIqrVMB7UsSXsOSFJEcnoJhAJOM+Q0MkR04LGCeHWBGI754jIkFb/ww3Rbphn2nd07wfXCIdV3wOz01IZQ7huDXtGSGnnLKj1LQZJYqtnM5sYO+Tz1ZLLqKlyPLZzFZ1VtoIwnto+TggHdso9OQZFITM0M4WxiTMhXLeIPSEkmdxXK0m6voX+u+ZDsVPMOESty2uYQ0bketCAr3B++BaHkEtmwrwhZlphb38vIBP2xTEoqmvC+KnOm+G9ho4SssjOMWRMQzJcYjrTOw5Bld2i2GJtF12gaAKqe/PcpI48h/N03EzxkeVyTze0Rw5pfZVV9xuevieVcfzU3nmPvYKOEbLIzjHeYiLDMUPMtwjRid0twu262J6zIRAvrqKlV8NhK2pLwPQ8Zu9p7we/KKL7p9ul6LU06ytCIWdluA5oHW0npPm+vw8ydg4hHYzgWVV0ti1J1GdqiFZdF2VyxHxux3wSZXJD8zwdJdP96MKcMXvv1A5SP4OsHsILLwZCloG2ErLQzuF2djFVxmwB49k93Koc2NYFi1egmHO5E8ZtvmmsG4JHxPTI3o9lSIk0/A/fu4WDhw7hxMlnEdA62kZI184xkCEavn1jDe6tjG6rR645zbgbrrOEgg3R7j3MBVkfkVllhZl9ZHbUrPCPQBwDlaciZK/iRAjXpaF0QhIH3xN2zqRj5xB4GobJrmHp1iWJ857ZNcLtRbudFJcQtLhK5ZTqdfYcllFTAzfM5/NN7uWNRa1H9x7D92/J1yFcl4dSCenaOQZSb5zwq/JCXjAupqa9JRX0yJgJlTbX04/6dcTyCpdTtQIyF5Mxnwaw7JBF5rpofiaE65JRCiHlBvFzdhOnNDLCzwmVl8jkbhF2RzFFTBt0Myv4DEG4Q4gCkzu3zMDkkUDeysnc2yW8G7q3IzaRMYTr8tEyIYmE9G0FVWM0w6qi6Uf7vWi9lQm9D1NFA8gUHi6BUhIZdSogI9MXuiEbmXt4qogi8jkhOhOuo8x1Q1P35OsQrstF04QssnMINkSbnjPT3RU/RMeOt8g046IiZdL3zYbY/NR3hoBF5Mvcy+aNTmrAis/1rhNHNBfCdTvQFCGpYHkvY3ITikJ0+u2oTsESO4WL9bl9D9B9bl9bf9FVw/Q+PH9N8XIF5hUx9mfakbMs2d2JoYHHU2AiXI+/8ioCykXDhKSF+VupYtbU5rr3nC43gFp0Zb5CgzveYlFV7JPIJZBrdKvuiX2NLYoUN/zzYiVlWw1p+KodPdZm+MRZNIJzX7va0Pm/+KvPod+wa0KSnUMmt131Z/NF2/5zxsUSnlvjYkjKNBlthySvbIBPChPO09Yh18sTwAqImyEbK1A6+MMZ6j2bx2b/HVLS1jYx8PCuDNUjR48ioFzsipCenWMqXFhVjHXHxQ5CFM80cvcr18C2rGD9kO1OdFtLyAvZmevc1iJy+aI5n/k/W/4f0sseOM+RW91X/AHNGHU8g2bB3/7tbT9nl/8D/YptCVk0swg9FMtTGyffafGIyG0VHbF8T3nL5QXwiQS4Kge4QlYcov28z50Eyvqb6t5Mh/IMGZl/r+jWDVnMnA7VdVuwJSF/UU0EGX2Tm6BCdEYRtY9YLwjT5upsfgZkVIshk7+5RDX6mA3j2XvBzy2RD8cu4YEM6QuJbf8gBm79BGxtFa999tcQ0B7kCKnsnESE6TiTTykCKvtGkxHWRyxcdKXnDvNkM3fc6j2WU0r3fK8ahlUwj8RAoRr6oV2dD2CL9MH5fH42qGMH4BEyO7PIudMCzKxl8atp7o+LqQvgbklCKFLA9H1dInkhmevrPRIhPdtey9NH/+eoe0b67Mj5+0qJXaSyzK7Pltc9uIfoZz+Uz1/7lQvoFjRatbeKTlT9KSGL7ByC23HJLsj3F1w5IZpbtSJSgRXkeW7hkCGHJBa3xMhul2euySlr7jM7nGGg+Zz74zAE9HJW4TVGN36U2jzBCG8/JCH//s4qqgeGcx/KfBEO8cCcWcViVZTVL2OOCubJKB8jJ7ympPIrapZVTI2s6iJzb4JddlD8OT2nZausXtP5o6ig11bka4jH6JEwv+dnvN8HtQmJlN2CXvQpJSFnZir4xrWbODea4NKlz+LYsVEvF7RLC7guZJijknadixuijU8JFJAxzQOzIRzY3NjAZnUDhpCVSiXNA2kjUAM6h76QCLUqsLGOL545bn9WfVP6hfI1EY6e63+ZaK25PbmJiK92UbjuVUhCfvXiCfzbx+O49ngGH7z9rzjzwnN4/eIFnBw/iZHRUUnCtfWNtNuytFhJVXKFtp5zbriyvGyfVxSB6HMiz4YgG/HOPDefVZaW0TSWF8QPeorf/71fRztRZu7Yzz7jThhMRLxdnXuMr18YwperY2AX3sTk7Q8xOflfCFAIlXXnMFgTeRQdbxyPcPmlQbx97yDYp98Av3Nd5FItKFcPoSx17MfedKOIaD2x2W3hz18exBvHIrkVMSklxoMqBHXsLCIBjI2NpW98/VeHMDqo69yJ82DP9/eI1euhK9NRyAbGwYMHceKE+saA059iuPzygD1DEJJNnBN9s67f/bl0nJ44E3zHDiOdLyBCEjEJb03o0G0wflaF8JP9tXfNa+eCzdNpeN/CMD4+TjFcPv/ni8Np6JagvPLsZ8A+8zn5iGNjpX0HdDeC1LGbTPB+gReHBwcHpVLOzc0JMgpSvi6soOuZDdTpu1cOnAYzalmvA+vCb1yrgJMnuLneE9V5UMe9QS4xPHbsGFZXV7G+vi6tIArf33xY3+YOg+pLgsTBRGiX0CSVBBVExfqy7KbsFwR13DsUViqnTp3C/fv3Qab5ZWEFfe9JjOkqx66hScrcr1YjQgpiciIoEZVUtV5Ht4GI2C51DGtqdkYhISmPJFJOT0/L0C27ONdb/O4TGepFHnrMWkxSPTerjpLuPUm7bYCi37Cll0MVN4XvxcVFp4tTMlkOjcpjW5LSY4fQqQGKsKZma2xrLlKBQ/kktRapi/Ph0wQfLiZoK7YiqSiU+MpC+rxsEBkvvRlae3uNbQlpujgUugnUxfnStU1U6g3kk2XAkNT1QbWC8unbQG0DrcCQMYTqvceO7RfTxVlYWEi7OH97uwuKEV3ZY1D04Y8cx+e/+LtYXlpEZWkJC3NPsLa+Jl9vh0HRw3/p5Vdx5pXXwrcndAl21Q8kQpINRAfZQN+b7UDobhBEKGrz0XFWb3FCqQaRcl4QdFkQtUbftiUIbJYi0LGfidjTa2p2AnVxHjx4IK0g6uL81v9udD50NwiXpAH7A7sm5K66OAEdRS/6lFEjJ5MNZAYwTBcnIKBMNMyolrs4AWFNzTZoSCHlBbqLQzBdnICAstBUzO1IF6cHEdbU7IyGFdKACpzcWpyAgBbRNIu2W4sTENAsWpK1bdfiBAQ0gZbj7LZrcQICGkQp7Nl2LU5AQAMohZCmi0MwXZyAgGZQWnwNXZyAMlBqwkeGuQnd1MWhQicgoBGUSsjQxQloFaWXxKaLQzBdnICA3aItHk3o4gQ0i7YwJXRxAppF26QrdHECmkFbY2no4gQ0irYzJHRxAhpB2wkZujgBjaAjMTR0cQJ2i44ldaGLE7AbdIyQoYsTsBt0tOwNXZyAndBxHyZ0cQK2Q8fZELo4AdthT+QpdHECtsKexcvQxQkoAuOc79k+KPV6Pd1RrVJHUzuq8flpYP4T/NmbrW3FfFikDb9xIsIhLdaHDh/GwEBQ7naCClxT5BrsKSEJtPsF7ahGoC2jG95RjbZ6XhCkrK4BSYxm8KIQ6r94ZQgnh5n8IvlnnnkGBw4cQEB7cfbsWXm42HPfpeHvxcni0AjYoXPq+caaIih9mwM9r+1M7i+MRfjjF9SvgUhIqYQx8AM6jz1XSAKFbLOjGoXuL13bKGdHNdp7fGPdEtTZLP/kMPCnZ4ZwfkSp4ujoKI4cOYKAzqFIIbuCkARSSLO5flOhe9c/aBl/9OwGfmd0DYkgKOWJx48fD/niHqCrCUmgXJJySsI/3a2XvqMa+Z1/d2EQn39WkY/C8/DwMFZWVlCtVhHQWXRlUeOCQvbDhw/lZvWEL/9os7TN9clWIhOefE8aiaM5TWM7BXQPuoqQBDd0Ux7Z6vfikCpefmkAb72oChf6iwyFS/ei6/6rlNnFOX+E4b1Lw5KMZtro5MmTgYxdjK5TSANSSVJLQjOh+62JAXz102qIg0hOIZpCdUB3o2sJ2WwXh1SVZi3J0yQlJLXNJs4B3YuuJSSh0S4OqSKNtI2IvJFMbgrRQRX3F7o6mdrtWhwqXGjxGIVoIiNdNzExEci4D9HVCknYqYsT7JzeQtcTkuBaQTdXuCRlsHN6E/uCkAS3i/Pvj2IZwkkViYCkiocPH0bA/se+IWS2i0MIdk7vYd8QkkBW0KNHjyQ5jx49GuycHgQR8vsICOgS/BJkuWygrFhLKgAAAABJRU5ErkJggg==" alt="envelope" width="164" height="131" />
                          </xsl:if>
                          <xsl:if test="//Title/@MessageType=1">
                            <img src="data:image/png;base64,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" alt="coffee" width="120" height="124" />
                          </xsl:if>
                          <xsl:if test="//Title/@MessageType=2">
                            <img src="data:image/png;base64,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" alt="sad" width="96" height="105" />
                          </xsl:if>
                          <xsl:if test="//Title/@MessageType=3">
                            <img src="data:image/png;base64,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" alt="clock" width="164" height="131" />
                          </xsl:if>
                        </td>
                      </tr>

                      <!-- отступ -->
                      <tr>
                        <td height="10"></td>
                      </tr>

                      <!-- информация о задании -->
                      <tr>
                        <td style="padding-left: 20px;padding-right: 20px;">
                          <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse;">
                            <!-- на исполнение -->
                            <tr>
                              <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #606060;">На исполнение:</td>
                              <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #000000;padding-left: 30px;">
                                <a style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #000000;">
                                  <xsl:attribute name="href">
                                    <xsl:value-of select="//Employee/AdditionalInfo/OpenCard/@Link"/>
                                  </xsl:attribute>
                                  <xsl:value-of select="//Data/CardTask/@Description"/>
                                </a>
                              </td>
                            </tr>
                            <!-- автор -->
                            <tr>
                              <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #606060;">Автор:</td>
                              <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #000000;padding-left: 30px;">
                                <xsl:variable name="authorId" select="//Data/CardTask/MainInfo/@Author"/>
                                <xsl:call-template name="getemployeedisplayname">
                                  <xsl:with-param name="employeerow" select="//*/EmployeesRow[@RowID=$authorId]"/>
                                </xsl:call-template>
                              </td>
                            </tr>
                            <!-- исполнители -->
                            <tr>
                              <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #606060;">Исполнители:</td>
                              <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #000000;padding-left: 30px;">
                                <xsl:for-each select="//Data/CardTask/MainInfo/Performers/PerformersRow">
                                  <xsl:value-of select="current()/@EmployeeDisplayString"/>
                                  <xsl:if test="position() != last()">
                                    <xsl:text>, </xsl:text>
                                  </xsl:if>
                                </xsl:for-each>
                              </td>
                            </tr>
                            <!-- контролёр -->
                            <xsl:if test="//Data/CardTask/MainInfo/@Controller">
                              <tr>
                                <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #606060;">Контролёр:</td>
                                <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #000000;padding-left: 30px;">
                                  <xsl:variable name="controllerId" select="//Data/CardTask/MainInfo/@Controller"/>
                                  <xsl:call-template name="getemployeedisplayname">
                                    <xsl:with-param name="employeerow" select="//*/EmployeesRow[@RowID=$controllerId]"/>
                                  </xsl:call-template>
                                </td>
                              </tr>
                            </xsl:if>
                            <!-- срок до -->
                            <tr>
                              <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #606060;">Срок до:</td>
                              <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #000000;padding-left: 30px;">
                                <xsl:variable name="enddate" select="//Data/CardTask/MainInfo/@EndDate"/>
                                <xsl:choose>
                                  <xsl:when test="string-length($enddate)>0">
                                    <xsl:call-template name="convertdate">
                                      <xsl:with-param name="str" select="//Data/CardTask/MainInfo/@EndDate"/>
                                    </xsl:call-template>
                                  </xsl:when>
                                  <xsl:otherwise>
                                    <xsl:text>
																			не указан
																			</xsl:text>
                                  </xsl:otherwise>
                                </xsl:choose>
                              </td>
                            </tr>

                            <!-- Завершено -->
                            <xsl:variable name="endDateActual" select="//Data/CardTask/MainInfo/@EndDateActual"/>
                            <xsl:if test="string-length($endDateActual)>0">
                              <tr>
                                <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #606060;">Завершено:</td>
                                <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #000000;padding-left: 30px;">
                                  <xsl:call-template name="convertdate">
                                    <xsl:with-param name="str" select="$endDateActual"/>
                                  </xsl:call-template>
                                </td>
                              </tr>
                            </xsl:if>

                            <!-- дата контроля -->
                            <xsl:if test="//Data/CardTask/MainInfo/@ControlDate">
                              <tr>
                                <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #606060;">Дата контроля:</td>
                                <td valign="top" style="height: 24px;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #000000;padding-left: 30px;">
                                  <xsl:variable name="controlDate" select="//Data/CardTask/MainInfo/@ControlDate"/>
                                  <xsl:choose>
                                    <xsl:when test="string-length($controlDate)>0">
                                      <xsl:call-template name="convertdate">
                                        <xsl:with-param name="str" select="//Data/CardTask/MainInfo/@ControlDate"/>
                                      </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                      <xsl:text>
																					не указан
																				</xsl:text>
                                    </xsl:otherwise>
                                  </xsl:choose>
                                </td>
                              </tr>
                            </xsl:if>
                            <!-- отступ -->
                            <tr>
                              <td height="20"></td>
                            </tr>
                          </table>
                        </td>
                      </tr>

                      <!-- Описание задания -->
                      <xsl:if test="//CardTask/MainInfo/@Content">
                        <xsl:if test="not(//Title/@MessageType=0)">
                          <tr>
                            <td style="padding-left: 20px;padding-right: 20px;font-size: 15px;line-height: 140%;font-family: Roboto, Arial, Helvetica, sans-serif;">
                              <div style="font-weight: bold;color: #000000;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;">
                                Описание задания
                              </div>
                              <xsl:call-template name="LFsToBRs">
                                <xsl:with-param name="input" select="//CardTask/MainInfo/@Content"/>
                              </xsl:call-template>
                            </td>
                          </tr>
                        </xsl:if>
                      </xsl:if>

                      <!-- отступ -->
                      <tr>
                        <td height="16"></td>
                      </tr>

                      <!--Комментарии-->
                      <xsl:variable name="delegatecommentvalue">
                        <xsl:call-template name="delegatecomment" />
                      </xsl:variable>
                      <xsl:if test="string-length($delegatecommentvalue)>0">
                        <tr>
                          <td style="padding-left: 20px;padding-right: 20px;font-size: 15px;line-height: 140%;font-family: Roboto, Arial, Helvetica, sans-serif;">
                            <div style="font-weight: bold;color: #000000;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;">
                              Комментарии
                            </div>
                            <div>
                              <xsl:value-of select="$delegatecommentvalue"/>
                            </div>
                          </td>
                        </tr>
                        <tr>
                          <td height="16"></td>
                        </tr>
                      </xsl:if>

                      <!--Отчет-->
                      <xsl:variable name="taskreport" select="//Data/CardTask/MainInfo/@Report"/>
                      <xsl:if test="string-length($taskreport)>0">
                        <tr>
                          <td style="padding-left: 20px;padding-right: 20px;font-size: 15px;line-height: 140%;font-family: Roboto, Arial, Helvetica, sans-serif;">
                            <div style="font-weight: bold;color: #000000;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;">
                              Отчет
                            </div>
                            <div>
                              <xsl:value-of select="$taskreport"/>
                            </div>
                          </td>
                        </tr>
                        <tr>
                          <td height="16"></td>
                        </tr>
                      </xsl:if>

                      <!-- кнопки -->
                      <tr>
                        <td style="height: 80px;padding-left: 20px;padding-right: 20px;">
                          <table border="0" width="100%" cellpadding="0" cellspacing="5">
                            <tr>
                              <xsl:for-each select="//Employee/Operations/Operation">
                                <td style="font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #2f7da8;padding-right: 10px;padding-left: 10px;padding-top: 5px;padding-bottom: 5px;border: 1px solid #2F7DA8;cursor: pointer;text-align: center;">
                                  <a style="font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #2f7da8;cursor: pointer;text-align: center;text-decoration: none;">
                                    <xsl:attribute name="href">
                                      <xsl:value-of select="current()/@Link"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="current()/@Name"/>
                                  </a>
                                </td>
                              </xsl:for-each>
                            </tr>
                          </table>
                        </td>
                      </tr>

                      <!-- связанный документ -->
                      <xsl:if test="//LinkedDocument != ''">
                        <tr>
                          <td class="pad2">
                            <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse;">
                              <tr>
                                <td style="width: 20px;"></td>
                                <td colspan="2" style="font-weight: bold;color: #000000;font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;">
                                  Связанный документ:
                                </td>
                                <td style="width: 20px;"></td>
                              </tr>
                              <tr>
                                <td height="8" colspan="2"></td>
                              </tr>
                              <tr>
                                <td style="width: 20px;"></td>
                                <td>
                                  <div style="font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #000000;padding-left: 30px;">
                                    <xsl:value-of select="//LinkedDocument"  disable-output-escaping="yes"/>
                                  </div>
                                </td>
                                <td style="width: 20px;"></td>
                              </tr>
                            </table>
                          </td>
                        </tr>
                      </xsl:if>
                    </table>
                  </td>
                </tr>

                <!-- подсказки -->
                <xsl:if test="//Title/@MessageType=0">
                  <xsl:if test="//Employee/Hints/Hint">
                    <tr>
                      <td style="width: 16px;"></td>
                      <td style="background-color: #c0c0c0;padding: 9px 20px 9px 20px;line-height: 120%;font-weight: 300;font-size: 14px;font-family: Roboto, Arial, Helvetica, sans-serif;">
                        <xsl:for-each select="//Employee/Hints/Hint">
                          <xsl:value-of select="current()/@Text" disable-output-escaping="yes"/>
                          <br/>
                        </xsl:for-each>
                      </td>
                      <td class="margin" style="width: 16px;"></td>
                    </tr>
                  </xsl:if>
                </xsl:if>

                <!-- подвал -->
                <xsl:if test="//Title/@MessageType=0">
                  <tr>
                    <td style="width: 16px;"></td>
                    <td style="font-size: 11px;font-family: Roboto, Arial, Helvetica, sans-serif;line-height: 140%;color: #ffffff;padding-top: 15px;padding-bottom: 80px;">
                      Вы получили это письмо, поскольку являетесь зарегистрированным пользователем Docsvision и адрес
                      <a class="link" style="font-size: 11px; color: #ffffff;">
                        <xsl:attribute name="href">
                          mailto:<xsl:value-of select="//Employee/@Email"></xsl:value-of>
                        </xsl:attribute>
                        <xsl:value-of select="//Employee/@Email"></xsl:value-of>
                      </a>
                      указан в настройках справочника сотрудников. Для изменения настроек уведомлений обратитесь, пожалуйста, к администратору системы.
                    </td>
                    <td style="width: 16px;"></td>
                  </tr>
                </xsl:if>
                <xsl:if test="//Title/@MessageType=1">
                  <tr>
                    <td style="width: 16px;"></td>
                    <td style="font-size: 11px;font-family: Roboto, Arial, Helvetica, sans-serif;line-height: 140%;color: #000000;padding-top: 15px;padding-bottom: 80px;">
                      Вы получили это письмо, поскольку являетесь зарегистрированным пользователем Docsvision и адрес
                      <a class="link" style="font-size: 11px; color: #000000;">
                        <xsl:attribute name="href">
                          mailto:<xsl:value-of select="//Employee/@Email"></xsl:value-of>
                        </xsl:attribute>
                        <xsl:value-of select="//Employee/@Email"></xsl:value-of>
                      </a>
                      указан в настройках справочника сотрудников. Для изменения настроек уведомлений обратитесь, пожалуйста, к администратору системы.
                    </td>
                    <td style="width: 16px;"></td>
                  </tr>
                </xsl:if>
                <xsl:if test="//Title/@MessageType=2">
                  <tr>
                    <td style="width: 16px;"></td>
                    <td style="font-size: 11px;font-family: Roboto, Arial, Helvetica, sans-serif;line-height: 140%;color: #ffffff;padding-top: 15px;padding-bottom: 80px;">
                      Вы получили это письмо, поскольку являетесь зарегистрированным пользователем Docsvision и адрес
                      <a class="link" style="font-size: 11px; color: #ffffff;">
                        <xsl:attribute name="href">
                          mailto:<xsl:value-of select="//Employee/@Email"></xsl:value-of>
                        </xsl:attribute>
                        <xsl:value-of select="//Employee/@Email"></xsl:value-of>
                      </a>
                      указан в настройках справочника сотрудников. Для изменения настроек уведомлений обратитесь, пожалуйста, к администратору системы.
                    </td>
                    <td style="width: 16px;"></td>
                  </tr>
                </xsl:if>
                <xsl:if test="//Title/@MessageType=3">
                  <tr>
                    <td style="width: 16px;"></td>
                    <td style="font-size: 11px;font-family: Roboto, Arial, Helvetica, sans-serif;line-height: 140%;color: #ffffff;padding-top: 15px;padding-bottom: 80px;">
                      Вы получили это письмо, поскольку являетесь зарегистрированным пользователем Docsvision и адрес
                      <a class="link" style="font-size: 11px; color: #ffffff;">
                        <xsl:attribute name="href">
                          mailto:<xsl:value-of select="//Employee/@Email"></xsl:value-of>
                        </xsl:attribute>
                        <xsl:value-of select="//Employee/@Email"></xsl:value-of>
                      </a>
                      указан в настройках справочника сотрудников. Для изменения настроек уведомлений обратитесь, пожалуйста, к администратору системы.
                    </td>
                    <td style="width: 16px;"></td>
                  </tr>
                </xsl:if>

              </table>
            </td>
            <td></td>
          </tr>
        </table>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>