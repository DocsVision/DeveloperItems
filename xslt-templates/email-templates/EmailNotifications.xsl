<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output encoding="utf-8" method="html" indent="yes" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

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
			<xsl:text></xsl:text>
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

			<body style="margin:0; padding:0" class="bg">
				<table align="center" width="600" border="0" cellpadding="0" cellspacing="0" style="border-collapse:collapse;">
					<tr>
						<td style="width: 16px;"></td>
						<td height="90" align="center">
							<xsl:if test="//Title/@MessageType=0">
								<img src="data:image/png;base64,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" alt="Docsvision logo" width="200" height="42" />
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
							<table align="center" width="600" border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; background: #ffffff">

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
											<img src="data:image/png;base64,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" alt="envelope" width="254" height="168" />
										</xsl:if>
										<xsl:if test="//Title/@MessageType=1">
											<img src="data:image/png;base64,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" alt="coffee" width="254" height="168" />
										</xsl:if>
										<xsl:if test="//Title/@MessageType=2">
											<img src="data:image/png;base64,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" alt="sad" width="254" height="168" />
										</xsl:if>
										<xsl:if test="//Title/@MessageType=3">
											<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAP4AAACoCAYAAADAQVO7AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAABsiSURBVHgB7Z17jFzVfcd/5+7D9tre9ZpljYG1zStgg01DK0ghNJVCFZG+aKWqVZMINVJIBDRVo6a0qPkjTUWgVJWalhTSf4KUNFiqBEhtAAm1UIIbEKAE29hAbGzvLmsv+5z17s7szNzT8zuve+5jxjs7d2Zn5v4+6DJ3Zu7cWXn3e37Pcw7jAiAIIlN4QBBE5iDhE0QGIeETRAYh4RNEBiHhE0QGIeETRAYh4RMXJC8Kvs/OluGbb88A0RmQ8ImqnCpwePxsCd4878N/f1SAfzo8DUT7Q8InEkEr/8JcGb7/UQmmixzK4vlNuwfhb9+YhNMLRSDaGxI+EeOs0DVa+UMLPpR8kKIv+Ry6uzzYsrkX/uSlMSDaGxI+EeI14dI/LpQ/U0Ir7x5iABCDwBUXb4GXP1wkl7/NIeETEuHVw5PCrf+xOClxZeWLvhK7tPrC4pfEAHDJtj55/dcOTcDPp/NAtCckfAJ+Kqz8E+dKcEIE9r4WOR54LgcBFL0eBLo8Zj/3+y+chrlCGYj2g4SfYTCB99R0GZ4XVn6xzG0sL/QthW5EX+ZMufri8J25nKdEku+bb00C0X6Q8DMKlunQyh9b9qUlN1beiL/km9ieqXOd5FuYDdfyv/P2NLw8sQhEe0HCzxho5Z/XZbqZohE019bdWHlmk3nSA7CWnsPMxARAYTl0zy/+zxi5/G0GCT9DYJkOrTxm7n1twd34veRYfWX5leDxnInQnon/Tv/iZOy+6PJ/8aVxINoHEn5GkGW6c0Vp5VXWngcW3pTrIIjl8T1ff5YxFdgv5hZgYlQIvLsndv9nT+WoxNdGkPA7HFOme06ccC3yUllZeRO7lyLWvyTcAbxO5e+5+CNh8nxidEyk9bvVkQB19bUPJPwOxpTpPsirON1N0gUHvqcTeDqW97Vrj+CDdPPFcfitnwEM7qj4fXMrZerqaxNI+B2IW6Zb9oOuu6jgSwlZe3TqUeTSykvBq0d086cnp4ANDFf9burqaw9I+B2GW6bjRvCmNGe78PCR2Y48ZfWVdfcYgGnRYc7x7pF3ADZsqmrxDdTV1/qQ8DsENZvOl/H8rMjYcZ24K/oqmWfjeKf/3rj/nDtq5yh+JgcAc0jhHz0GsHX7qn8e6uprbUj4HYCx8j89X1blNyl6bmvwblNOKWT1Qfr1zAg8euj7fygy+QvzC8Auumz1PxN19bU0JPw25+Vc2Vp5nweTaUyiLmi7BRnPm4EANW+seci1d19jyvq/e+SYcvNrsPgIdfW1LiT8NsWU6V7KqVjeZu2BhSx62ed2tp2x+j5+QJfrjNi9yCNizsexjFej6A3U1deakPDbEFOmQxffdeVNLT4o3TkZfd2Qg1l7GcNrc2+tPr6m72+SfMj4mbGa3XwX6uprTUj4bYSx8i84ZTq3C8+02Sa33XItaBZ250GJXg0JYVcfxX98jW6+C3X1tR4k/DbheB5bbpWVR4maeN53ps2W3Ak3ziCArr2sx0M4aReU73iQxQczOKjj5Psn6xK9gbr6WgsSfotjZtMdnCpD3rrxzky6Ch15pnwnp9Z4nvpFMyemZ4E779brbceeeDx2+B0o5AvAhvdAvVBXX2tBwm9hTusyHU6wQXzr1qvMvRkESrZWj334Op6XVt5YeB648Cz4pUdLd0yr3sT9J987qdz8vq2QBtTV1zqQ8FsUs7T1HDbj8MC6u5bduPZuUg/z55xzlcCDeMzuaUffvgZB3C8n5Gjx5+ZzcALd/G0X7tSrBerqaw1I+C0GJvCemCzJzD3i82DmXLQ0Z+fSOwMBwhLabsE+cqdhh9nEnszqm8QflvDOqEw8G94NaUNdfesPCb+FMGW6sytOAo9zp1TnrorD7Ko5xgsI6vDRUl0Qz3uhJB9+i1vP59YLeEfE99LFR1c/Zairb/0h4bcAbpkOE3hG9G7SzsbxunRXLIdn1NnJNbrbrsux3kHZDv/PHfEzO/vO0xU9fEA3fwwt/hpr96uBuvrWFxL+OvNunttmnKBMFzTkGNfel+vgRVfNiVps8wvlYOvy4GTxwbH4YGJ8E9dz6+qPGTc/5fg+CnX1rR8k/HXClOl+NFWSVh6xXXiuC68HgaLTpOPrxTNsXI4fdrP14CTzQll7fFcPFjbbr2N8CDL8b73+M1W7b4Cb70JdfesHCX8dOBUp06EUbV+9bsopcbcuz9TmFqb1lmvRat/cFXboHKKLahjrz0INPe7z3FwOJic/WnOLbq1QV9/6QMJvMmjlnzRlOoBgsQw7o44Fu9e42Xvj2rOg154BC1l3gIiFhyCTDxCU79y6PeNOB5+x9kgK3Xqrhbr6mg8Jv0nIpa0nw1beT+i8CzazCPfcS9cegkQd4nlh6x5y9Z2LGQtPxgl5BV5wHQ4o75sW3Qa7+S7U1dd8SPhNAMWOVh7LdAh3GnFKkQk1xvKXnK48zoO6u7sqTtSlD58zvZKO8gs8t2YPca8A7zl6egzmhavfLDffhbr6mks3EA0Dy3TPzqiMvcEuhMG505wT1OzNKre+vsZ00rmWPkjUxcUPwMLr5rGIl+DE9vbz+r2NH56Ez1zWB9fcfCVAb/MsvuHEzDJMLa5AuzK0uRfaBRJ+g/j5og/Pz/s2Yy8XywBnVp0dAJTAzbkZFDg3FjosXs/ptGNuyc4eZnotC72nPgv2NXNf1cKrvIC9pVn4tRv3wC037oT1YpqE3xRI+CmDZbpnZ8pwfNm3r3HHmocFHj4Pdq9hwSo4EctuXXU9CSd+jRJyUN8P7gUQz/qbQaR35hx0LS/C5dftBaLzIeGnCM6me2a2LDP2iM3ac73vPDhi98OuvbH0zGmwMaU6fRq33Cws9iDud6w9g0TX3r0fegno5iPDOy8FovMh4acAWvmX5ssyiccc82rdemARkasGnKhrH0vA6fuEhBqK35kaWcDJ2KstMRJKehBL6oF+7pWL0DM5BjsuuRR6enqA6HxI+HWCZbqD02qVWylZK3BX3E4iz3nfzJsHp8EGOE9wx8OCtYOD4yGA9RTC5Trg4IQEJj8QHgw2nBsDr1iEHWTtMwMJvw5wNh1OrEGMkCom7XT8rvruk137kEvOkl17gxvzg3sPbfWt+D3jQWhvIGEA6RXWHi09ufnZgYS/BpLKdCZrbzL2MQuP7r6TzYeEdfBcVz7Z4jNQW1bHE3fB9VGPwfyMuuvPZPF1I4+3tAg9wuIPj+wmNz9DkPBrBON4XMvelulAi57z5Ey9tfDBgIAELnqFhBtLiNsrJPAQL8FTiIcJrquv7tUzo+bF79jZ/KYdYv0g4a+SaJmO6//5oBJzZcedN3PpbSMORFx7FB53RJoU0wM45Ttmm3OC1411Z3FvwfECoh6EfMn5TO/4SWnpd+xcv9o90XxI+KsAXfpnnTIdgqLB6N4k6AJxR5J5vnoPnF57pkcNbfNj1j5YETew0MEAoKy/lzgQVAgbTNwfifE9UbfvFhYf3XwiW5Dwq4BW/uV5X25G6eJX6Liz8b0Tz+N5kKkPFOruPx/K5APEX3eFDayy0CFyD4BweZA5CT5xYFIPuXwXCT9rkPArYMp00sprEYYacqIdd6EYn1vX3tPKTXbj1Q0rNuR4wbRZ6x0kuPOhMIHFcwXAE+4tPJCeD47Dpr4+2D50MRDZgoSfgFumkziiL/k8IYHHbRJPufzc7jOfbIldKwwJCT63KSch9oeEpJ77vv4O6d5zff/QzyJChdysdPW3k5ufSUj4DkllOgSfuVY9GstHy3dG2BIWT66Bs85d4lRZ6WEAMLdsl3Av9VqQ7QcIDx5BmMBin9tw6ri8ntz8bELC16CVfxnLdI7m8dRPEHfQax+fcBO26vF18AAgSNbpRy8Wh4PMAHqRnvukc3Am60S7+/TtIVzXV3jTk+TmZ5jMCx+FfnCqBKdXVLutgbtlOJ85cX20z14NAtxm3Vk84cYqxOUATsbdET8EF4euc0Ru3ox5CpH7x69B0Z8jNz/jZFr46NIfnC7bZhxDNGsf7a8v6/Kdb3rtGVNZevwwiwpakTgQ2KNCpt71BJxSHLjfA7oHn+tynbkfQNwT0M+7x9RMPHLzs0smhW9m072+yKWV5yZxDyZrb4QfrGVvLTyE3ftQr33IogeDSXhyjDr3EtxzgKDEZ+vuEB40EnMG7ko9kQFEfb/5LnXfrily87NO5oSf2IzDILRllXTlQwtdcr1jDdN72OGnkpfFim09LYXMdbIumEATfM5p5DGirrjIRvjc9SCCRGH8M/Y6HCDOjgITbv6Oq64GIrtkSvhYojObUbrIrD2KvMxtOc5PSNyZLjweEa8rLvMamNdDlj08MUddW13k0eehll+buWfx7478XOZ51zndtDOyB4jskgnhY5kOm3HMKreGqGvvrpATqtfr+ryeOp+8YGWSpdff40VjdX1lkAuICDR0HxMmmMk6Qe9+LDegT9zvDw1CxRXoGv1AuvhbBwaAyC4dL/zobDqDde19HmvGCZ6zoNceYW4ffURUAFW8AFes6nlSjM+i9zYuPGjrrt8MSoRONSAp1xD5OQNrvxuaxaZDr8DGw4eh7/9egQ1HDkPX/Bx4uXn5nt8/ACsiwVga2QX56/fD8q23w9JttwPReETYxzl0IInNOFxbeRaeKhueThueYIMz75CklljrZodicrdDjkcsdsJg4cyND1l95/vMHHpzf/UYXBv9mcL3N+8z6H7xGegT9/n137gTGomXm4PBJ/4Vtn/vMSvy1VIUg8CSGACmv/7X4rx5A1QaXDu8BdqFjhT+8bwvRJ9s5TkPz5pLnjOvsvnas7ckJc3iYnPcek/V3o3wbHmPRRbgYEkDQtJgw6om+Kp5IV3vHgZPHAc+/itwWYPKeCj4oUcfhkEh+DSY/8PPtdUA0E7C76iddLBM98KcDwenwrV53TpvY/dgiypzmL3pzA42vhW9EZBnH8MbVhi1hUQcem52slHnuOeduxuOu1d9bJsrphqCPD1sMBYfLKKhgmzQsd+hh4vpSSl6LOE1SvSD3/suXPXLN6QmemTg4A9h5Pc+C/1P/RCIdOmYGD+pTGfEK0XvJ82qM1NnIVSrD5XpeHTNO25vGpTfHOvLg0w7Cy2i4Vpjk6hTFQK1fV0kgccSFtjQ3wUswSNwLb72MuS9RTLPO/KG/K5rrt0HjWD4G3+VquBdekbPwM4/+wpsPPI2TP7dI0CkQ0e4+mjlo3PmESV4tby1nUXnByvgBuvhmbZbsM0wUl+OtUdCbj242XoTx2tXn5nFLSHRNdcfk5teBu8xG/ODuZaxmNBj99IveM7PIF8StXrv8Juibq8Semjtb7ntU/IxLdC1v+zuP4Y+kcCrBCbw8jccgPN3/pZI3n1SJvPwNfX5eSloTPr1vfoKbHn+P6t+H95n9Okf28+3GhTjN5FHTixCfkN86yKfm/o8d1a1jUyj5cGsO4gl38LNNkjSnnTMET+LdOeFpsK6VtsLLLcX+bz6HmY/Y77XeBig74Fr4bNiMbjv0nkRo6yIRyH4iTHh3p8L/Xtcc91euDpli7/707cK4R5OfA/FOfvle2HmnvtWLVS07gMHfyBdezxPAhN/KP5WhITfRL52aAK+/9oxuLbfh0/c8nHYtq0/XJvnPLI6TjCzzkzEQRLd6qiFZcyuZe9aeCO+QqEAhXzBfj6XWwAj6vn5nL0uL65ZEQesLANbycOduweD70HxFtX+cV6pKNLcK/aHwBVx1wJa+bQz+dXc+3otM4p+6NGHoP9gcmw/+6V7W9LtJ+E3kanFAtz0H7+A8bPngH/wNuweuQQO3LgPhoaHYEv/VlmOW1rO2wad+dmcnW67ML8g72EEv+CIcyG3YL+jKASd14KW4haHwdxjTSzMAJyfhX/83U9AI0k7kz8gLPIlIu6uxtRfPCgz8vUw+G/fheG/eSDxvclvPQKz99wLrQQJv0n4wocfHR2FVycL8IW3hGUsLAN/73X52BY0QfhpW/ue0dMy017JFXdJQ/yY2b/kq/FBxh8YgBNvHG2peJ/KeU2iKGJcPG4e9OD+K0SBYsMmYB+7GaBvKxCKtDP5Q49+e1Wil9f+w0Nwkbi+HrCWn+TWe/PzMPT3DwGxNtpa+LgevNn95U+v7Iabt3lK/PtuA9jRHk0fjSTtuj1a+6S42zTaJJGG+DGmT3LrMRSotTOQULS18D1RDxseHrbPH76+B/q7dUZ8ZC+wS7M99RRj+zQZShAwtthOf/3Bqm59GuLH+ye59YNPNKZ/oNNp+869TZs2wfbt2+X5ZRsZ3H9lV/CmED4buQ6gK3vrjVw2sjv1hTY2JdTrc8Lao/iRRoofY/qZL8et/nZh9Yna6YiWXRQ+DgDI3SPa5Tfs2KNc/6Fs7Q13zXXpxvYo+qTYfv6PPh963kjxz34p3hOAsT42/xC10TG9+jt27JCuP/LYjb3W5Zdg3L9nP7D9n5KPsG24oxOAaO3T7NBDksSF3XjG2rs0Svxo9bFHIMqGo28DURsdI/zu7m7r8vcLz/6xAwlbPosBAC0/u/om6QWwX7oD2LU3q3CggwaDtK09svFovENv6dZPVry+UeI/f+dvxl7rO/QTIGqjo4Lfbdu2weLiIiwvL8sSH7r9T46WKn9ADBawdbs8mAgJJCVx/XIOONbYl3LifKF9+gKgMdYe6TlzOvZa4foDVT+D4keSRI7iR2qt8yct1LHhCFn8Wum4rNfOnTvh1KlTsrnnflHie/GjMozna+hR0oMB27o9eA2FLwYAjgMBDghiYJADRIuBgm+EtUeS4vv8/gMX/Fza4i9eHi9PdlFJr2Y6TvgY56P4x8fHpcv/8L4e1dVXDxgiYJ5gW1A6lN7ASt7xDNZ/MMB18hth7ZGkevlqu+bSFL+fsFYgJviI2ujIOhdm+NHtn5ubs119//JByqLs65dH1cEAH5sECv7qBs23T4NGuP3E2unYAjcm+jDex5Ze7Op7fdaH1+d8aCiVBoMlESacn7HnaWPm2jcStO5Rq4/Pa+mVT0P8SdbdpxWDa6ZjhW+6+tDlR7Cr767XViBXavKcJDMYuH0E2iPg4+/h1D+oh0YssJFEeSAu/J4zZ6Bww36ohXrFn1S6K16+C4ja6OiWNtPVNzMzY7v6HnqvBZJyupIA3aLkuGUQ7vjs78DC/BzkhDWbmfoIlpaX5PNqdPf0wBVXXg27r7rGzldoJAVRP48m+PoO/W/NwkfqEf/GhAx+kfYArJmO72VF4WN5Dw8s77042QSXv0ZQuNhei8cevbUVhigo/mkxECyIAaFYKkKPGCjMnnd4NEPwBqzZb3kuvDTWluf+C2bvuQ/WwlrFn1SzxzX5idrIRBM7dvWdEW4plviwq+/Trxaa7/LXiDsYtAKFhI65jcLtrjXOd6lV/Dg7MDr4ILgRB1EbHbW8diVW1dVHVAXXukvqk693dlwtHX79B/89do3cgIN236mZTAgfwfKemchjuvqI2qg0O67eOfGrET9a+4GnfhB7f4ms/ZrIjPARbOwxE3mwqw8TfsTqwdlxUdJaCedC4q+03BeuBUDUTqaEb7r6ENPVR6werJdXWgkHd9Kpl2riT5wS7KwFQNRGpoSPmK4+xK7VR6yaSivhDH/jgYrLYdd6/9V08JmVf4i1kTnhI5joi63VR6wKtPpTf5ksuJ1f/UrDLb+9RoierP3ayeRffLW1+ogLU2nxSwQtPy6Hjcm4tYJbc3nzuYrv43fjkl/E2smsqau6Vh9xQXBDi0oZdbPLrcnGrxYUPH6m2q67+Rv2y+8m6qMjNs2sB+zlx64+5AtvrjS1q49Pj4u09Idw7IE/gHYEM/q7hMAvtPQVLtG19Ku3y/be/P79IkegciwodOz373v1J3LDTGzHrVYaxIFm/Mkf0aaZKZB54ZdKJdvVlytBU7v62l34BnTv04jtq4HufatbetpJp42grr76QUGe/c7jDUm2oXWf/NbD5N6nDKWzgbr60gBr6qNPP5dq0g2t/Ik3j655IhBRGRK+hrr66gct/oSw/CffOBraaKMW0MJjKe/998eklW/VeL7dyXyM74JJPrNwB67YU/dafRegU2L8avQdegU2vfqKSNwdlt13mOU3CTwUdXlgGxSu3y8n2mDyr51779spxief1qEpa/VlDBQyTaRpPcjVj0BdfUQWoL/qCNTVR2QBEn4C1NVHdDok/ApU3YGXINoc+muuQtUdeAmijSHhV4G6+ohOhYR/Aairj+hESPirgLr6iE6DhL8KaK0+otMg4a8SWquP6CRI+DVAXX1Ep0B/uTVAXX1Ep0DCrxHq6iM6ARL+GqCuPqLdofn4aySNtfrMfPz7btsH9bBZhBu3b/egTzsffZs3Q1cXeSKNBBO9JtlrGNrcC+0CCb8OcN7+1NSUPF/Twh1LC8BnhPjzSwB+GdbCLuF4/PlVPTDUy4AxBhdddBFs2LABiMayZ88eebQrVJOqAxzxFxcX5co9pqvvydEaFu7o2wqs7zp1XlhSA8FyTp0XLzyIfGbYg89frn6FKHYMQUyjEUFUgyx+naCrf+rUKevy3/VaAcbzKfyTFgtiAFgOBgIxKBiGhEd5z+4e2LtVWfn+/n7YsqV9ln3qBNrd4pPwU6Bpa/UtL8DnLi7Ab/cvgS8GAozjBwcHKZ5fB0j4hARjfYz5kX8+WUp9rT7sF/j2vm6442IlcnTre3t74fz585DP54FoLknJvXaChJ8S6OqPjo5CsViUz9PcjgvLhdgshH0DOFUY1wkw5USCWAsk/BRxXX6M8+96baWu7bjQyt9/RRfcvUsl8NDCUAKPSAP6C0qRNLv69m5h8MwtvVL0Znbg0NAQiZ5IBbL4DaDeHXjvHumCBz+mJgPhYIKuPbr4BJEWJPwGsNauPvQScK4/9gSgZUfvoZ0TSETrQsJvELV29aGVx6m+W0Vcj8046NqTlScaBQWMDWK1a/VhAg8X8UTXHkWPnxsZGSHREw2FLH4DuVBXH5XpiPWChN9g3BLfsfNcip/KdMR6Q8JvAm5X39MTZen6o5VHoaOV37x5MxBEMyHhN4FoVx9CZTpiPSHhNwks8U1MTMhBYGBggMp0xLpCwieIDELZJILIICR8gsggJHyCyCAkfILIICR8gsggJHyCyCAkfILIICR8gsggJHyCyCAkfILIICR8gsggJHyCyCAkfILIICR8gsggJHyCyCAkfILIICR8gsggJHyCyCAkfILIICR8gsggJHyCyCAkfILIICR8gsggJHyCyCAkfILIICR8gsggJHyCyCAkfILIICR8gsggJHyCyCD/Dy2K7TGR9gQhAAAAAElFTkSuQmCC" alt="clock" width="254" height="168" />
										</xsl:if>
									</td>
								</tr>

								<!-- отступ -->
								<tr>
									<td height="10"></td>
								</tr>

								<!--Предупреждение, что не все файлы прикреплены-->
								<xsl:if test="//SendInfo/@TooLargeAttachments='true'">

									<tr>
										<td style="padding-left: 20px;padding-right: 20px; font-family: Roboto, Arial, Helvetica, sans-serif;font-size: 15px;color: #606060;">Не удалось приложить к заданию все приложенные файлы в связи с ограничением размера вложений. Полную информацию по заданию можно получить, открыв карточку Docsvision.</td>
									</tr>

									<!-- отступ -->
									<tr>
										<td height="10"></td>
									</tr>

								</xsl:if>

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
									<xsl:if test="//States/StatesRow/@BuiltInState!='86BD2ACD-C9C1-4165-BCF9-232D96EC8AAD'">
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
															<xsl:value-of select="//LinkedDocument" disable-output-escaping="yes"/>
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
			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>