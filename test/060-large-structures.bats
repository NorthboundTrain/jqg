#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/060-large-structures.bats
#----------------------------------------------------------------------
#--- run some tests on very large JSON files
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; make_temp_dir; }
teardown() { load common; common_teardown; remove_temp_dir; }


@test "regex look-behind (LS1)" {
    run jqg '(?<!n)ae' $large_structure1_json
    assert_success
    assert_output - <<EOF
{
  "ac.0.veri.similique.0.4.2.facilis.discere.0.nihil.0.0.1": "dictas vitae",
  "ac.0.veri.similique.0.4.2.facilis.discere.1": "nisi cibo graeco nonumes",
  "ac.0.veri.similique.0.4.2.facilis.discere.2.3.2": "agam simul quaerendum nascetur",
  "ac.0.veri.similique.0.4.2.facilis.discere.2.4": "proin epicuri phaedrum",
  "ac.0.veri.similique.0.4.2.facilis.discere.2.5.0.2.sociosqu.dapibus": "causae vulputate nisi eros",
  "ac.0.veri.similique.0.4.2.facilis.discere.2.5.2.dicit.iusto.3": "solum curae eiusmod",
  "ac.0.veri.similique.0.4.2.facilis.discere.2.5.2.lucilius.2.4": "amet graecis",
  "ac.0.veri.similique.0.4.2.facilis.discere.2.5.2.vix.1.aeterno": false,
  "ac.0.veri.similique.0.4.2.facilis.discere.2.5.2.vix.1.velit": "mandamus phaedrum",
  "ac.0.veri.similique.0.4.2.facilis.discere.2.5.2.vix.2.2": "aeterno erant constituam",
  "ac.0.veri.similique.0.4.2.facilis.discere.2.5.2.vix.2.5": "nihil curae",
  "ac.0.veri.similique.0.4.2.facilis.discere.2.5.3.4.elementum.3": "vitae viris pede cu",
  "ac.0.veri.similique.0.4.2.facilis.discere.2.5.3.4.elementum.5": "vulputate repudiandae",
  "ac.0.veri.similique.0.4.2.facilis.discere.2.5.5.4.2.1": "suas praesent fringilla",
  "ac.0.veri.similique.0.4.2.facilis.discere.3.semper.legimus.maecenas": 798,
  "ac.0.veri.similique.0.4.2.facilis.discere.3.semper.propriae": "imperdiet mi constituam",
  "ac.0.veri.similique.0.4.2.facilis.discere.3.semper.adversarium.1.1.phaedrum": "fusce impedit facilisis aptent",
  "ac.0.veri.similique.0.4.2.facilis.discere.3.semper.adversarium.1.1.conclusionemque": "constituam facete fusce sententiae",
  "ac.0.veri.similique.0.4.2.facilis.discere.3.semper.adversarium.2.4.2": "eu dissentiet copiosae",
  "ac.0.veri.similique.0.4.2.facilis.discere.3.semper.adversarium.2.4.5": "viverra saepe",
  "ac.0.veri.similique.0.4.2.facilis.discere.3.semper.adversarium.2.4.6": "nostro saepe omnis",
  "ac.0.veri.similique.0.4.2.facilis.discere.3.semper.adversarium.4.1.pretium": "aeque",
  "ac.0.veri.similique.0.4.2.facilis.discere.3.semper.fames.scriptorem": "propriae dictum",
  "ac.0.veri.similique.0.4.2.facilis.discere.3.semper.fames.conclusionemque.0.phaedrum": false,
  "ac.0.veri.similique.0.4.2.facilis.discere.3.semper.fames.conclusionemque.4.1": "aliquip omnesque curae soleat",
  "ac.0.veri.similique.0.4.2.facilis.discere.3.viverra": "sensibus pro propriae",
  "ac.0.veri.curae": true,
  "ac.0.eiusmod": "expetenda ut quaeque convenire",
  "ac.4.4": "ex graecis aperiam",
  "periculis.omnesque.2": "aenean eros",
  "periculis.omnesque.4.graeco": true,
  "periculis.omnesque.4.contentiones": "quaerendum",
  "fames.4.hac.integre.0": "nostrud quisque definitionem sententiae",
  "fames.4.hac.integre.3.2.tantas": "erroribus graeco magnis",
  "fames.4.hac.integre.5.0.0.alia.3.3.0.0.0.4.voluptaria": "euismod everti molestiae definitionem",
  "fames.4.hac.integre.5.0.0.alia.3.3.0.0.0.5.0": "graecis",
  "fames.4.hac.integre.5.0.0.alia.3.3.0.0.2.dicit": "tibique praesent",
  "fames.4.hac.integre.5.0.0.alia.3.3.0.0.4": "consul modus copiosae eam",
  "fames.4.hac.integre.5.0.0.alia.3.3.0.3.3.pertinacia.vulputate": "praesent atomorum liberavisse",
  "fames.4.hac.integre.5.0.0.alia.3.3.0.6.4.3": "causae salutatus possit ubique",
  "fames.4.hac.integre.5.0.0.alia.3.3.0.6.4.4.propriae": true,
  "fames.4.hac.integre.5.0.0.alia.3.3.0.6.4.5.quaestio": "salutatus",
  "fames.4.hac.integre.5.0.0.alia.3.3.0.6.4.5.quaeque": 1236,
  "fames.4.hac.integre.5.0.0.alia.3.3.0.6.4.6.1": "fastidii pertinacia aeterno",
  "fames.4.hac.integre.5.0.0.alia.3.3.4": "dissentiunt vituperatoribus aeque",
  "fames.4.hac.integre.5.0.0.alia.3.4.elitr.1.volumus.repudiandae": "inermis",
  "fames.4.hac.integre.5.0.0.alia.3.4.elitr.1.volumus.id.6": "graecis",
  "fames.4.hac.integre.5.0.0.alia.3.4.elitr.1.prima.mei.aenean": "lucilius honestatis",
  "fames.4.hac.integre.5.0.0.alia.3.4.elitr.1.prima.mei.probatus": "graeco meis",
  "fames.4.hac.integre.5.0.0.alia.3.4.elitr.3.2.1.2": "malis nec quaeque",
  "fames.4.hac.integre.5.0.0.alia.3.4.elitr.3.2.4.0": "saepe",
  "fames.4.hac.integre.5.0.0.alia.3.4.elitr.3.3.0.1": "ludus molestiae inciderint",
  "fames.4.hac.integre.5.0.0.alia.3.4.elitr.3.4.debet.graecis": "deserunt mediocrem aliquip",
  "fames.4.hac.integre.5.0.0.alia.3.4.elitr.4.a.1.volumus": "aenean error natoque"
}
EOF
}

@test "regex look-behind - keys-only (LS1)" {
    run jqg -k '(?<!n)ae' $large_structure1_json
    assert_success
    assert_output - <<EOF
{
  "ac.0.veri.similique.0.4.2.facilis.discere.2.5.2.vix.1.aeterno": false,
  "ac.0.veri.similique.0.4.2.facilis.discere.3.semper.legimus.maecenas": 798,
  "ac.0.veri.similique.0.4.2.facilis.discere.3.semper.propriae": "imperdiet mi constituam",
  "ac.0.veri.similique.0.4.2.facilis.discere.3.semper.adversarium.1.1.phaedrum": "fusce impedit facilisis aptent",
  "ac.0.veri.similique.0.4.2.facilis.discere.3.semper.fames.conclusionemque.0.phaedrum": false,
  "ac.0.veri.curae": true,
  "periculis.omnesque.4.graeco": true,
  "fames.4.hac.integre.5.0.0.alia.3.3.0.6.4.4.propriae": true,
  "fames.4.hac.integre.5.0.0.alia.3.3.0.6.4.5.quaestio": "salutatus",
  "fames.4.hac.integre.5.0.0.alia.3.3.0.6.4.5.quaeque": 1236,
  "fames.4.hac.integre.5.0.0.alia.3.4.elitr.1.volumus.repudiandae": "inermis",
  "fames.4.hac.integre.5.0.0.alia.3.4.elitr.1.prima.mei.aenean": "lucilius honestatis",
  "fames.4.hac.integre.5.0.0.alia.3.4.elitr.3.4.debet.graecis": "deserunt mediocrem aliquip"
}
EOF
}

@test "regex look-behind - values-only (LS1)" {
    run jqg -v '(?<!n)ae' $large_structure1_json
    assert_success
    assert_output - <<EOF
{
  "ac.0.veri.similique.0.4.2.facilis.discere.0.nihil.0.0.1": "dictas vitae",
  "ac.0.veri.similique.0.4.2.facilis.discere.1": "nisi cibo graeco nonumes",
  "ac.0.veri.similique.0.4.2.facilis.discere.2.3.2": "agam simul quaerendum nascetur",
  "ac.0.veri.similique.0.4.2.facilis.discere.2.4": "proin epicuri phaedrum",
  "ac.0.veri.similique.0.4.2.facilis.discere.2.5.0.2.sociosqu.dapibus": "causae vulputate nisi eros",
  "ac.0.veri.similique.0.4.2.facilis.discere.2.5.2.dicit.iusto.3": "solum curae eiusmod",
  "ac.0.veri.similique.0.4.2.facilis.discere.2.5.2.lucilius.2.4": "amet graecis",
  "ac.0.veri.similique.0.4.2.facilis.discere.2.5.2.vix.1.velit": "mandamus phaedrum",
  "ac.0.veri.similique.0.4.2.facilis.discere.2.5.2.vix.2.2": "aeterno erant constituam",
  "ac.0.veri.similique.0.4.2.facilis.discere.2.5.2.vix.2.5": "nihil curae",
  "ac.0.veri.similique.0.4.2.facilis.discere.2.5.3.4.elementum.3": "vitae viris pede cu",
  "ac.0.veri.similique.0.4.2.facilis.discere.2.5.3.4.elementum.5": "vulputate repudiandae",
  "ac.0.veri.similique.0.4.2.facilis.discere.2.5.5.4.2.1": "suas praesent fringilla",
  "ac.0.veri.similique.0.4.2.facilis.discere.3.semper.adversarium.1.1.conclusionemque": "constituam facete fusce sententiae",
  "ac.0.veri.similique.0.4.2.facilis.discere.3.semper.adversarium.2.4.2": "eu dissentiet copiosae",
  "ac.0.veri.similique.0.4.2.facilis.discere.3.semper.adversarium.2.4.5": "viverra saepe",
  "ac.0.veri.similique.0.4.2.facilis.discere.3.semper.adversarium.2.4.6": "nostro saepe omnis",
  "ac.0.veri.similique.0.4.2.facilis.discere.3.semper.adversarium.4.1.pretium": "aeque",
  "ac.0.veri.similique.0.4.2.facilis.discere.3.semper.fames.scriptorem": "propriae dictum",
  "ac.0.veri.similique.0.4.2.facilis.discere.3.semper.fames.conclusionemque.4.1": "aliquip omnesque curae soleat",
  "ac.0.veri.similique.0.4.2.facilis.discere.3.viverra": "sensibus pro propriae",
  "ac.0.eiusmod": "expetenda ut quaeque convenire",
  "ac.4.4": "ex graecis aperiam",
  "periculis.omnesque.2": "aenean eros",
  "periculis.omnesque.4.contentiones": "quaerendum",
  "fames.4.hac.integre.0": "nostrud quisque definitionem sententiae",
  "fames.4.hac.integre.3.2.tantas": "erroribus graeco magnis",
  "fames.4.hac.integre.5.0.0.alia.3.3.0.0.0.4.voluptaria": "euismod everti molestiae definitionem",
  "fames.4.hac.integre.5.0.0.alia.3.3.0.0.0.5.0": "graecis",
  "fames.4.hac.integre.5.0.0.alia.3.3.0.0.2.dicit": "tibique praesent",
  "fames.4.hac.integre.5.0.0.alia.3.3.0.0.4": "consul modus copiosae eam",
  "fames.4.hac.integre.5.0.0.alia.3.3.0.3.3.pertinacia.vulputate": "praesent atomorum liberavisse",
  "fames.4.hac.integre.5.0.0.alia.3.3.0.6.4.3": "causae salutatus possit ubique",
  "fames.4.hac.integre.5.0.0.alia.3.3.0.6.4.6.1": "fastidii pertinacia aeterno",
  "fames.4.hac.integre.5.0.0.alia.3.3.4": "dissentiunt vituperatoribus aeque",
  "fames.4.hac.integre.5.0.0.alia.3.4.elitr.1.volumus.id.6": "graecis",
  "fames.4.hac.integre.5.0.0.alia.3.4.elitr.1.prima.mei.probatus": "graeco meis",
  "fames.4.hac.integre.5.0.0.alia.3.4.elitr.3.2.1.2": "malis nec quaeque",
  "fames.4.hac.integre.5.0.0.alia.3.4.elitr.3.2.4.0": "saepe",
  "fames.4.hac.integre.5.0.0.alia.3.4.elitr.3.3.0.1": "ludus molestiae inciderint",
  "fames.4.hac.integre.5.0.0.alia.3.4.elitr.4.a.1.volumus": "aenean error natoque"
}
EOF
}

@test "deep extraction - single (LS1)" {
    run bash -c "jqg -x .fames[4].hac.integre[5][0][0].alia[3][4].elitr[1].prima.mei.scriptorem -t flatten -V -r $large_structure1_json | grep -v null"
    assert_success
    assert_output "amet"
}

@test "deep extraction - structure (LS1)" {
    run jqg -x .periculis $large_structure1_json
    assert_success
    assert_output - <<EOF
{
  "periculis": {
    "omnesque": [
      21,
      "viverra iisque sadipscing constituto",
      "aenean eros",
      true,
      {
        "voluptatum": 1164,
        "id": 576.922,
        "sagittis": "quidam",
        "graeco": true,
        "pertinacia": "et",
        "contentiones": "quaerendum"
      }
    ],
    "wisi": [
      "vero",
      "definitiones duis",
      -504,
      false,
      620.756
    ],
    "eu": {
      "vocibus": "dolor idque inciderint porta",
      "virtute": 780,
      "dissentiunt": "euismod",
      "nascetur": "decore"
    },
    "latine": [
      "veri cum nusquam",
      "nulla",
      578.048,
      {
        "dolor": "id",
        "idque": [
          true,
          "vituperatoribus",
          "quod expetendis felis aliquet",
          924,
          false,
          "adhuc"
        ],
        "mnesarchum": -228,
        "feugiat": true,
        "referrentur": "luptatum condimentum ut"
      },
      779
    ],
    "platonem": [
      368,
      "mel verear",
      {
        "te": "massa nulla",
        "meliore": "hac",
        "sanctus": "sonet",
        "audire": 974.922,
        "mundi": "ea",
        "quem": "ornare conceptam voluptatibus vehicula"
      },
      -196.001,
      739.584
    ],
    "conceptam": 307.847,
    "quod": "adipiscing quis"
  }
}
EOF
}



@test "simple search I (LS2)" {
    run jqg socio $large_structure2_json
    assert_success
    assert_output - <<EOF
{
  "contentiones.2.0.1.tamquam.nonumes.1.dicat.integre.3.5.eiusmod.4": "ne sociosqu te possit",
  "contentiones.2.0.1.tamquam.nonumes.1.dicat.referrentur.dolores.0.detracto.2.lacinia": "non sociosqu",
  "contentiones.2.0.1.tamquam.iuvaret.dissentiunt.comprehensam.veri.noster.veritus.quaeque.1.4": "ludus sit sociosqu"
}
EOF
}


@test "simple search II (LS2)" {
    run jqg dicam $large_structure2_json
    assert_success
    assert_output - <<EOF
{
  "contentiones.2.0.1.tamquam.nonumes.0.dicam": "delenit natoque quot",
  "contentiones.2.0.1.tamquam.iuvaret.singulis.intellegebat.suscipit.0.4.1.dicam": "malis voluptatum adipisci"
}
EOF
}

@test "simple value search (LS2)" {
    run jqg -v quae $large_structure2_json
    assert_success
    assert_output - <<EOF
{
  "contentiones.2.0.1.tamquam.nonumes.1.dicat.integre.3.1.0.5.labore": "soluta definiebas vel quaeque",
  "contentiones.2.0.1.tamquam.nonumes.1.dicat.integre.3.5.purus.adversarium.vituperata": "nemore reprehendunt quaerendum conceptam",
  "contentiones.2.0.1.tamquam.nonumes.1.dicat.integre.3.5.luptatum.1.1": "elementum te dissentias quaeque",
  "contentiones.2.0.1.tamquam.nonumes.1.dicat.referrentur.petentium.3.2.3": "quaerendum",
  "contentiones.2.0.1.tamquam.nonumes.1.dicat.referrentur.dolores.0.detracto.1.2": "evertitur quaestio intellegebat",
  "contentiones.2.0.1.tamquam.nonumes.1.dicat.referrentur.dolores.2.5.6": "quaeque vivamus",
  "contentiones.2.0.1.tamquam.iuvaret.dissentiunt.comprehensam.veri.sapientem.splendide.3": "quaestio cum"
}
EOF
}

@test "simple extract (LS2)" {
    run jqg -x .contentiones[2][0][1].tamquam.iuvaret.singulis $large_structure2_json
    assert_success
    assert_output - <<EOF
{
  "contentiones": [
    null,
    null,
    [
      [
        null,
        {
          "tamquam": {
            "iuvaret": {
              "singulis": {
                "nostrud": false,
                "intellegebat": {
                  "possim": false,
                  "netus": -443,
                  "suscipit": [
                    [
                      true,
                      [
                        1001,
                        [
                          1222,
                          "nihil",
                          [
                            "dicta melius enim",
                            "evertitur",
                            -21,
                            984.834,
                            "molestiae oblique",
                            940.914,
                            "maluisset numquam maluisset necessitatibus"
                          ],
                          -463,
                          [
                            false,
                            "prodesset tota eligendi adipiscing",
                            "doming ferri ut errem",
                            -523,
                            127,
                            703.142
                          ],
                          true
                        ],
                        690,
                        {
                          "discere": "disputando",
                          "ludus": [
                            128,
                            -27.883,
                            "fastidii eleifend comprehensam do",
                            -402,
                            "copiosae",
                            "noluisse referrentur vivendum",
                            "inceptos"
                          ],
                          "partiendo": 226,
                          "principes": 1150,
                          "enim": [
                            true,
                            "laudem",
                            "ridiculus putent esse",
                            false,
                            false,
                            "philosophia",
                            "quem incorrupte quidam"
                          ],
                          "omnesque": "fabellas"
                        },
                        false,
                        "voluptatibus",
                        "diam"
                      ],
                      {
                        "neglegentur": true,
                        "viris": 135,
                        "hac": 743.52,
                        "constituam": [
                          882,
                          842,
                          true,
                          [
                            "dictas verear",
                            1250,
                            true,
                            "oportere",
                            false,
                            -424.313
                          ],
                          244.918,
                          280
                        ],
                        "posuere": true,
                        "dicant": "nobis",
                        "eiusmod": [
                          "quot",
                          [
                            "democritum",
                            "mutat",
                            "morbi adversarium mauris lobortis",
                            "utinam condimentum ornare sale",
                            "hendrerit",
                            891
                          ],
                          [
                            424,
                            false,
                            "saepe oblique dolorum",
                            1370,
                            1146.409,
                            "denique",
                            true
                          ],
                          [
                            "curae risus",
                            "sem rutrum nobis",
                            "voluptatum",
                            875.728,
                            "ex accusam",
                            687.529
                          ],
                          {
                            "omnesque": true,
                            "quem": -178.997,
                            "volutpat": "partiendo",
                            "quam": "leo",
                            "consul": true,
                            "utamur": "quodsi"
                          }
                        ]
                      },
                      490,
                      [
                        [
                          -199,
                          857,
                          -88.572,
                          "sem luptatum dictas suspendisse",
                          [
                            -35.271,
                            "reprimique adolescens dicta tincidunt",
                            "ornatus purus pro",
                            true,
                            "numquam",
                            "quidam platonem instructior iracundia",
                            "tacimates facete prodesset legendos"
                          ],
                          [
                            "dui",
                            false,
                            false,
                            "intellegebat malis",
                            "tritani"
                          ],
                          [
                            "erroribus vituperata epicurei sale",
                            "eam tempor",
                            "atqui ex",
                            "essent suavitate scelerisque aeque",
                            false,
                            "menandri efficitur"
                          ]
                        ],
                        {
                          "semper": {
                            "dolorum": "dissentiunt",
                            "feugiat": "sonet",
                            "volutpat": "cibo",
                            "option": 847,
                            "a": "munere deserunt solet",
                            "signiferumque": true
                          },
                          "mauris": "discere imperdiet reprimique arcu",
                          "prima": [
                            "nulla quam petentium",
                            178.034,
                            733,
                            "auctor",
                            true,
                            496,
                            544
                          ],
                          "alterum": 876,
                          "atomorum": {
                            "epicuri": "habitant eros",
                            "wisi": "netus ludus et lucilius",
                            "voluptatibus": "maximus theophrastus",
                            "fermentum": 75,
                            "concludaturque": "reprehendunt principes postea",
                            "harum": 1275,
                            "non": "faucibus"
                          },
                          "dicam": "malis voluptatum adipisci"
                        },
                        "verear",
                        "vero posse iriure sitlorem",
                        {
                          "dapibus": [
                            "modus",
                            769
                          ]
                        }
                      ]
                    ]
                  ]
                }
              }
            }
          }
        }
      ]
    ]
  ]
}
EOF
}

@test "jqx extract (LS2)" {
    run jqx .contentiones[2][0][1].tamquam.iuvaret.singulis dicam $large_structure2_json
    assert_success
    assert_output - <<EOF
{
  "contentiones.2.0.1.tamquam.iuvaret.singulis.intellegebat.suscipit.0.4.1.dicam": "malis voluptatum adipisci"
}
EOF
}



@test "simple search array (LS3)" {
    run jqg sollicit $large_structure3_json
    assert_success
    assert_output - <<EOF
{
  "0.4.2.dapibus.4.3.1.2.1.sollicitudin": 606,
  "0.4.2.dapibus.4.3.1.2.2.1.1.esse.0.possit": "sollicitudin",
  "0.4.2.dapibus.4.3.3.0.2.dicit.justo.3.6.1": "sollicitudin",
  "0.4.2.dapibus.4.3.3.0.2.dicit.justo.6.5.erroribus": "sollicitudin",
  "0.4.2.dapibus.4.6.4.blandit.0.0.ex.magnis.1": "sollicitudin adhuc sea",
  "0.4.2.dapibus.4.6.4.blandit.0.0.case.ne.qui": "sollicitudin"
}
EOF
}

@test "simple search array (LS3) <jqu>" {
    run jqu malis $large_structure3_json
    assert_success
    assert_output - <<EOF
[
  [
    [
      null,
      "malis"
    ],
    null,
    null,
    null,
    [
      null,
      null,
      {
        "dapibus": [
          null,
          null,
          null,
          null,
          [
            null,
            null,
            null,
            [
              null,
              [
                null,
                null,
                [
                  null,
                  {
                    "ex": "malis"
                  }
                ]
              ]
            ],
            null,
            null,
            [
              null,
              null,
              null,
              null,
              {
                "blandit": [
                  [
                    {
                      "ex": {
                        "equidem": [
                          null,
                          null,
                          null,
                          null,
                          [
                            null,
                            null,
                            null,
                            null,
                            null,
                            "malis albucius sapientem vehicula"
                          ]
                        ]
                      },
                      "case": {
                        "ne": {
                          "malis": [
                            false,
                            557,
                            "vituperata",
                            598,
                            "nascetur",
                            -398,
                            "aptent"
                          ]
                        }
                      }
                    }
                  ]
                ]
              }
            ]
          ]
        ]
      }
    ]
  ]
]
EOF
}



@test "simple search (LS4)" {
    run jqg integer $large_structure4_json
    assert_success
    assert_output - <<EOF
{
  "regione.definiebas.salutatus.2.vivamus.0.4.1.democritum.5.4.do.probo.integer": 751,
  "homero.1.0.3.2.voluptaria.0.ullamcorper.0.3.vitae.0.5.2": "integer odio",
  "maecenas.1.0.1.persequeris.suavitate.0.duo.debet.hendrerit": "quot integer",
  "maecenas.1.0.1.persequeris.suavitate.1.dicat.integre.3.5.purus.senserit": "integer quas cubilia",
  "dolorum.0.0.2.1.maximus.0.0.4.conubia.disputationi.0.aeterno.quando": "simul temporibus integer",
  "eos.1.0.modus.1.2.2.0.4.pertinax.2.1.0.2": "est adhuc integer",
  "eos.1.0.modus.1.2.2.0.4.suas.3.legendos": "integer appellantur",
  "eos.1.0.modus.1.2.2.1.0.1.4.antiopam.partiendo.integer": "indoctum risus",
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.mutat": "ultricies scelerisque urbanitas assentior",
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.case.0": 845.864,
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.case.1": "cibo",
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.case.2": 781,
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.case.3": 478.695,
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.case.4": "convallis deseruisse interpretaris efficiantur",
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.case.5": 651,
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.case.6": true,
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.vituperata.0": "tota",
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.vituperata.1": 537,
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.vituperata.2": 600.643,
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.vituperata.3": "iriure vestibulum per maluisset",
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.vituperata.4": "conceptam aliquando",
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.vituperata.5": "evertitur vehicula",
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.rhoncus.per": -661,
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.rhoncus.error": "ei nascetur",
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.rhoncus.duo": true,
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.rhoncus.complectitur": "probatus malesuada disputando essent",
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.rhoncus.essent": "etiam",
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.rhoncus.aliquip": "consul ipsum tantas",
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.rhoncus.mediocrem": "pellentesque",
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.decore.0": "maiestatis",
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.decore.1": true,
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.decore.2": false,
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.decore.3": "dui propriae",
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.decore.4": 491,
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.decore.5": "modo suas nisi",
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.eu.0": "himenaeos appellantur iudicabit assum",
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.eu.1": false,
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.eu.2": "tollit",
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.eu.3": "felis tota",
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.eu.4": false,
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.eu.5": "sanctus",
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.eu.6": 71.859,
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.instructior.0": -349,
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.instructior.1": "aeque salutandi fabulas elit",
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.instructior.2": true,
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.instructior.3": -474,
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.instructior.4": "maiorum ferri tacimates",
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.instructior.5": "facilis sit pro",
  "eos.1.0.modus.1.2.2.1.0.2.habitant.integer.instructior.6": -3
}
EOF
}

@test "simple search - values only (LS4)" {
    run jqg -v integer $large_structure4_json
    assert_success
    assert_output - <<EOF
{
  "homero.1.0.3.2.voluptaria.0.ullamcorper.0.3.vitae.0.5.2": "integer odio",
  "maecenas.1.0.1.persequeris.suavitate.0.duo.debet.hendrerit": "quot integer",
  "maecenas.1.0.1.persequeris.suavitate.1.dicat.integre.3.5.purus.senserit": "integer quas cubilia",
  "dolorum.0.0.2.1.maximus.0.0.4.conubia.disputationi.0.aeterno.quando": "simul temporibus integer",
  "eos.1.0.modus.1.2.2.0.4.pertinax.2.1.0.2": "est adhuc integer",
  "eos.1.0.modus.1.2.2.0.4.suas.3.legendos": "integer appellantur"
}
EOF
}

@test "simple search - values only (LS4) <jqu>" {
    run jqu -v integer $large_structure4_json
    assert_success
    assert_output - <<EOF
{
  "homero": [
    null,
    [
      [
        null,
        null,
        null,
        [
          null,
          null,
          {
            "voluptaria": [
              {
                "ullamcorper": [
                  [
                    null,
                    null,
                    null,
                    {
                      "vitae": [
                        [
                          null,
                          null,
                          null,
                          null,
                          null,
                          [
                            null,
                            null,
                            "integer odio"
                          ]
                        ]
                      ]
                    }
                  ]
                ]
              }
            ]
          }
        ]
      ]
    ]
  ],
  "maecenas": [
    null,
    [
      [
        null,
        {
          "persequeris": {
            "suavitate": [
              {
                "duo": {
                  "debet": {
                    "hendrerit": "quot integer"
                  }
                }
              },
              {
                "dicat": {
                  "integre": [
                    null,
                    null,
                    null,
                    [
                      null,
                      null,
                      null,
                      null,
                      null,
                      {
                        "purus": {
                          "senserit": "integer quas cubilia"
                        }
                      }
                    ]
                  ]
                }
              }
            ]
          }
        }
      ]
    ]
  ],
  "dolorum": [
    [
      [
        null,
        null,
        [
          null,
          {
            "maximus": [
              [
                [
                  null,
                  null,
                  null,
                  null,
                  {
                    "conubia": {
                      "disputationi": [
                        {
                          "aeterno": {
                            "quando": "simul temporibus integer"
                          }
                        }
                      ]
                    }
                  }
                ]
              ]
            ]
          }
        ]
      ]
    ]
  ],
  "eos": [
    null,
    [
      {
        "modus": [
          null,
          [
            null,
            null,
            [
              null,
              null,
              [
                [
                  null,
                  null,
                  null,
                  null,
                  {
                    "pertinax": [
                      null,
                      null,
                      [
                        null,
                        [
                          [
                            null,
                            null,
                            "est adhuc integer"
                          ]
                        ]
                      ]
                    ],
                    "suas": [
                      null,
                      null,
                      null,
                      {
                        "legendos": "integer appellantur"
                      }
                    ]
                  }
                ]
              ]
            ]
          ]
        ]
      }
    ]
  ]
}
EOF
}
