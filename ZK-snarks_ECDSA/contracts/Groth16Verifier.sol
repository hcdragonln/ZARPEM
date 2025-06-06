// SPDX-License-Identifier: GPL-3.0
/*
    Copyright 2021 0KIMS association.

    This file is generated with [snarkJS](https://github.com/iden3/snarkjs).

    snarkJS is a free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    snarkJS is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
    License for more details.

    You should have received a copy of the GNU General Public License
    along with snarkJS. If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity >=0.7.0 <0.9.0;

contract Groth16Verifier {
    // Scalar field size
    uint256 constant r    = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    // Base field size
    uint256 constant q   = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // Verification Key data
    uint256 constant alphax  = 4063645235232591856853271608352921426705112939121513654134827041487892914477;
    uint256 constant alphay  = 20688024684157040795929387352432628658618356773095612116456920183364119635284;
    uint256 constant betax1  = 4138736469534013311346246760153483120657273719774981528635963829525153058026;
    uint256 constant betax2  = 18141411206337867577722226654078696982429226343631748336532259357271029358106;
    uint256 constant betay1  = 13103302770448267639159843994430144272025314938800804026413078492472899842934;
    uint256 constant betay2  = 21223333558947368259208993822834970644958178930362033086005811422065636745978;
    uint256 constant gammax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gammax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gammay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gammay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 constant deltax1 = 8915583906348887685540070265211027901852283936802315330008923455139875123827;
    uint256 constant deltax2 = 16988382465127905369099377531228729687206788291392756281114899144453416640506;
    uint256 constant deltay1 = 10188203997679224696728780295284158362291937863464595073885351372789467300668;
    uint256 constant deltay2 = 14351524640626639001698416312696868911552331833052584599908809907038909825179;

    
    uint256 constant IC0x = 12988815623409671392559547851402001505651940496179356239441057110068322254009;
    uint256 constant IC0y = 6001320216462283135783913591766731395933322751214190649585494061520148221904;
    
    uint256 constant IC1x = 14156723251063471390283148972543149296996774517917089128561809879388327340952;
    uint256 constant IC1y = 17674127961810643441351583869751377831955561098448884207132479542123903910342;
    
    uint256 constant IC2x = 7518411792046747710410630950458191360844602680946124055373281754759299071978;
    uint256 constant IC2y = 13486808554318468457133397991561511856456999253643692717318220894109725771288;
    
    uint256 constant IC3x = 20876072676274321357940168049187986088851197270075812599022438086994558610009;
    uint256 constant IC3y = 19045053260527499258901010976539119782636812211030864791863497459284882681290;
    
    uint256 constant IC4x = 12847473204950000178064133204643570097282340268377167208191971004755362324466;
    uint256 constant IC4y = 6130460197927659378830854828471974707782854468114004675974982496802224707110;
    
    uint256 constant IC5x = 165860685851699776009127668494138499976219202962066599018175499179732977232;
    uint256 constant IC5y = 20038633747304478295759563961486246907761229610775830720894758636545924890200;
    
    uint256 constant IC6x = 21590980136876751431260826955091118378661330969219272409068618522831123008724;
    uint256 constant IC6y = 11674632632610985332430184465413647410215904209702566703395559119205867030302;
    
    uint256 constant IC7x = 18625181474881855658054757854429562359236944599726086366670660761359278052137;
    uint256 constant IC7y = 827456804976043777455597809591193147712387555631192412438614617991093337281;
    
    uint256 constant IC8x = 2605623010019231295513414049114539031368152625336832479217728581761111691954;
    uint256 constant IC8y = 7935965247776859210429997253466098530782284060752691580539991083150833758599;
    
    uint256 constant IC9x = 8822644209162726612106306454728544967305087766966482648912262282821992666876;
    uint256 constant IC9y = 4797571995960698583552545792143389610875004080050013822185222840878485608460;
    
    uint256 constant IC10x = 10047307420653543868000559159698148952254184573770572837370128642661501631965;
    uint256 constant IC10y = 1283442553969836987863462546786587601041385901029322013424401423441125938698;
    
    uint256 constant IC11x = 20291580958801397899971236826878917082172149477864666865403364742171292562825;
    uint256 constant IC11y = 10432113171738962572307159177840542819710678341169038000908313088372718829387;
    
    uint256 constant IC12x = 6125212951633867077932600009401350316773591257402806394999602698717478611045;
    uint256 constant IC12y = 17811615974602770558900972429675468311187886080392607886073134974880317803352;
    
    uint256 constant IC13x = 21525360559859500451433940532049207513956061237627188799478289792462340024529;
    uint256 constant IC13y = 16404929833631810144731346578588382264653208236724367162959249491513553518734;
    
    uint256 constant IC14x = 7387225135203501388379438260885379003660601785752602631138084883044553165759;
    uint256 constant IC14y = 4391975174103655229918924730601079798782203838376241467796936188842949128359;
    
    uint256 constant IC15x = 17271465225197477592242065633105964004174889832213754684460363514805253451040;
    uint256 constant IC15y = 10232719026387685456987351831146014320182399299217397380059989816664665234320;
    
    uint256 constant IC16x = 21875001386923102798624561878600540282916272135815494001199672317125364204450;
    uint256 constant IC16y = 3941405260746349432102020221977601141850752081708864414951662016738374815589;
    
    uint256 constant IC17x = 11335052108280460677128865719456697304327125041564326694448661053798086169056;
    uint256 constant IC17y = 3556461458668431483354160487860887527541541421778209112544817003271832316612;
    
    uint256 constant IC18x = 11106266438374172544379265760361479746761598487021395587113233603692088439212;
    uint256 constant IC18y = 2773741505853308491936530196782602950271373410779107364845209798930306520963;
    
    uint256 constant IC19x = 7388382756495599022548971831769045490928890455127852725964507467169415182094;
    uint256 constant IC19y = 13194309749017864033812703538496598265015870365585929459353227639258226712057;
    
    uint256 constant IC20x = 19274910794642912224895484088365080981540300765692197536224257504177118612972;
    uint256 constant IC20y = 472116151067660922186596060892786621796485764702921032988134643257736217836;
    
    uint256 constant IC21x = 845979822072796143385297040843693466656991689696377859997871817465601097979;
    uint256 constant IC21y = 3114374564560544946693976709182352714045673200064674020598222760957592771240;
    
    uint256 constant IC22x = 1891506515666422528596022675488408481183729597861831510117528938172813555625;
    uint256 constant IC22y = 759426715189575789235543752452728490351713193034576322501439882503761156927;
    
    uint256 constant IC23x = 12340700005997867821887198598892126016043856303518088357305813182366650767896;
    uint256 constant IC23y = 18603289879987146238610683469150324296766725360217282910345675614838093782836;
    
    uint256 constant IC24x = 20367402952309981978581840820654646779920816709864555559193485139020734846184;
    uint256 constant IC24y = 7707659943377604770412627935396895309357055174706391829093562478521097383005;
    
    uint256 constant IC25x = 13701485017973359365360568792263137633712429139998736213541060081478170989340;
    uint256 constant IC25y = 1405149476822386210201935816036114655467488713135672679989896126592834391073;
    
    uint256 constant IC26x = 9524792193442458604069346951949139644686811701149019328845906954343932940812;
    uint256 constant IC26y = 6327125612246722568247980303704615594502443041441267083242088649744545062229;
    
    uint256 constant IC27x = 12583979020108411585528279671910256438719543030606020738724834825567871882291;
    uint256 constant IC27y = 13194362608196491088991945834660655002055652321637417443007121299180434192752;
    
    uint256 constant IC28x = 8942388637790681426745133301794967638444518890425272129414879762972096723174;
    uint256 constant IC28y = 1616585663368191136040877130821910026137378352263035041701640414998580663708;
    
    uint256 constant IC29x = 11303726783462216355002980494572840964880066746219375937109625630591587021762;
    uint256 constant IC29y = 3417729434487584674891081814903863598596086148977584896948838042330322328341;
    
    uint256 constant IC30x = 20548989241555133348549354480011920414239392853641141317442946301832700435912;
    uint256 constant IC30y = 21453922073115025737211533308397486790388611068064305978118151153178492970088;
    
    uint256 constant IC31x = 5712372873578506016785686479154097250414898389473563985751468561166392576829;
    uint256 constant IC31y = 17502102282069980235648537561809091112130038499604220592637762737377032449992;
    
    uint256 constant IC32x = 6929393026095441482013610281989715645899130632896944446552372486600932400338;
    uint256 constant IC32y = 17511144559302147022664738425419059849929960233105950932749928848851081454379;
    
    uint256 constant IC33x = 17069467098275499589135827612369020545975254428719551315468247832904164955295;
    uint256 constant IC33y = 17371073817533458448750658531788034365006992271875442149286059252260533749309;
    
    uint256 constant IC34x = 9010177845820142538920238356211358914465128248850255849006236408433741493876;
    uint256 constant IC34y = 5652973418997940386260823971815231497401704745031117028437892471518271025724;
    
    uint256 constant IC35x = 11709880115093640099797089956598136288417286380496461724704411234040839209574;
    uint256 constant IC35y = 17544142005241413106330840230725736785493941077634229853971029940360856682454;
    
    uint256 constant IC36x = 4229457304635285430913779103543422238165818692697951092838686047750160817507;
    uint256 constant IC36y = 586874207655936741465531584480552092500449160663225536014918611442314960387;
    
    uint256 constant IC37x = 9806935311213015746528716140277944326726195009771069695431065762776284494524;
    uint256 constant IC37y = 6466517340505754047070407979865379589176359252035478525863267488463860518077;
    
    uint256 constant IC38x = 13482393408264777561811186813567106950482974993967457944763809999536432234949;
    uint256 constant IC38y = 7635864997605423795740785289282404891402384953031977317266938840689007194174;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[38] calldata _pubSignals) public view returns (bool) {
        assembly {
            function checkField(v) {
                if iszero(lt(v, r)) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }
            
            // G1 function to multiply a G1 value(x,y) to value in an address
            function g1_mulAccC(pR, x, y, s) {
                let success
                let mIn := mload(0x40)
                mstore(mIn, x)
                mstore(add(mIn, 32), y)
                mstore(add(mIn, 64), s)

                success := staticcall(sub(gas(), 2000), 7, mIn, 96, mIn, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }

                mstore(add(mIn, 64), mload(pR))
                mstore(add(mIn, 96), mload(add(pR, 32)))

                success := staticcall(sub(gas(), 2000), 6, mIn, 128, pR, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            function checkPairing(pA, pB, pC, pubSignals, pMem) -> isOk {
                let _pPairing := add(pMem, pPairing)
                let _pVk := add(pMem, pVk)

                mstore(_pVk, IC0x)
                mstore(add(_pVk, 32), IC0y)

                // Compute the linear combination vk_x
                
                g1_mulAccC(_pVk, IC1x, IC1y, calldataload(add(pubSignals, 0)))
                
                g1_mulAccC(_pVk, IC2x, IC2y, calldataload(add(pubSignals, 32)))
                
                g1_mulAccC(_pVk, IC3x, IC3y, calldataload(add(pubSignals, 64)))
                
                g1_mulAccC(_pVk, IC4x, IC4y, calldataload(add(pubSignals, 96)))
                
                g1_mulAccC(_pVk, IC5x, IC5y, calldataload(add(pubSignals, 128)))
                
                g1_mulAccC(_pVk, IC6x, IC6y, calldataload(add(pubSignals, 160)))
                
                g1_mulAccC(_pVk, IC7x, IC7y, calldataload(add(pubSignals, 192)))
                
                g1_mulAccC(_pVk, IC8x, IC8y, calldataload(add(pubSignals, 224)))
                
                g1_mulAccC(_pVk, IC9x, IC9y, calldataload(add(pubSignals, 256)))
                
                g1_mulAccC(_pVk, IC10x, IC10y, calldataload(add(pubSignals, 288)))
                
                g1_mulAccC(_pVk, IC11x, IC11y, calldataload(add(pubSignals, 320)))
                
                g1_mulAccC(_pVk, IC12x, IC12y, calldataload(add(pubSignals, 352)))
                
                g1_mulAccC(_pVk, IC13x, IC13y, calldataload(add(pubSignals, 384)))
                
                g1_mulAccC(_pVk, IC14x, IC14y, calldataload(add(pubSignals, 416)))
                
                g1_mulAccC(_pVk, IC15x, IC15y, calldataload(add(pubSignals, 448)))
                
                g1_mulAccC(_pVk, IC16x, IC16y, calldataload(add(pubSignals, 480)))
                
                g1_mulAccC(_pVk, IC17x, IC17y, calldataload(add(pubSignals, 512)))
                
                g1_mulAccC(_pVk, IC18x, IC18y, calldataload(add(pubSignals, 544)))
                
                g1_mulAccC(_pVk, IC19x, IC19y, calldataload(add(pubSignals, 576)))
                
                g1_mulAccC(_pVk, IC20x, IC20y, calldataload(add(pubSignals, 608)))
                
                g1_mulAccC(_pVk, IC21x, IC21y, calldataload(add(pubSignals, 640)))
                
                g1_mulAccC(_pVk, IC22x, IC22y, calldataload(add(pubSignals, 672)))
                
                g1_mulAccC(_pVk, IC23x, IC23y, calldataload(add(pubSignals, 704)))
                
                g1_mulAccC(_pVk, IC24x, IC24y, calldataload(add(pubSignals, 736)))
                
                g1_mulAccC(_pVk, IC25x, IC25y, calldataload(add(pubSignals, 768)))
                
                g1_mulAccC(_pVk, IC26x, IC26y, calldataload(add(pubSignals, 800)))
                
                g1_mulAccC(_pVk, IC27x, IC27y, calldataload(add(pubSignals, 832)))
                
                g1_mulAccC(_pVk, IC28x, IC28y, calldataload(add(pubSignals, 864)))
                
                g1_mulAccC(_pVk, IC29x, IC29y, calldataload(add(pubSignals, 896)))
                
                g1_mulAccC(_pVk, IC30x, IC30y, calldataload(add(pubSignals, 928)))
                
                g1_mulAccC(_pVk, IC31x, IC31y, calldataload(add(pubSignals, 960)))
                
                g1_mulAccC(_pVk, IC32x, IC32y, calldataload(add(pubSignals, 992)))
                
                g1_mulAccC(_pVk, IC33x, IC33y, calldataload(add(pubSignals, 1024)))
                
                g1_mulAccC(_pVk, IC34x, IC34y, calldataload(add(pubSignals, 1056)))
                
                g1_mulAccC(_pVk, IC35x, IC35y, calldataload(add(pubSignals, 1088)))
                
                g1_mulAccC(_pVk, IC36x, IC36y, calldataload(add(pubSignals, 1120)))
                
                g1_mulAccC(_pVk, IC37x, IC37y, calldataload(add(pubSignals, 1152)))
                
                g1_mulAccC(_pVk, IC38x, IC38y, calldataload(add(pubSignals, 1184)))
                

                // -A
                mstore(_pPairing, calldataload(pA))
                mstore(add(_pPairing, 32), mod(sub(q, calldataload(add(pA, 32))), q))

                // B
                mstore(add(_pPairing, 64), calldataload(pB))
                mstore(add(_pPairing, 96), calldataload(add(pB, 32)))
                mstore(add(_pPairing, 128), calldataload(add(pB, 64)))
                mstore(add(_pPairing, 160), calldataload(add(pB, 96)))

                // alpha1
                mstore(add(_pPairing, 192), alphax)
                mstore(add(_pPairing, 224), alphay)

                // beta2
                mstore(add(_pPairing, 256), betax1)
                mstore(add(_pPairing, 288), betax2)
                mstore(add(_pPairing, 320), betay1)
                mstore(add(_pPairing, 352), betay2)

                // vk_x
                mstore(add(_pPairing, 384), mload(add(pMem, pVk)))
                mstore(add(_pPairing, 416), mload(add(pMem, add(pVk, 32))))


                // gamma2
                mstore(add(_pPairing, 448), gammax1)
                mstore(add(_pPairing, 480), gammax2)
                mstore(add(_pPairing, 512), gammay1)
                mstore(add(_pPairing, 544), gammay2)

                // C
                mstore(add(_pPairing, 576), calldataload(pC))
                mstore(add(_pPairing, 608), calldataload(add(pC, 32)))

                // delta2
                mstore(add(_pPairing, 640), deltax1)
                mstore(add(_pPairing, 672), deltax2)
                mstore(add(_pPairing, 704), deltay1)
                mstore(add(_pPairing, 736), deltay2)


                let success := staticcall(sub(gas(), 2000), 8, _pPairing, 768, _pPairing, 0x20)

                isOk := and(success, mload(_pPairing))
            }

            let pMem := mload(0x40)
            mstore(0x40, add(pMem, pLastMem))

            // Validate that all evaluations ∈ F
            
            checkField(calldataload(add(_pubSignals, 0)))
            
            checkField(calldataload(add(_pubSignals, 32)))
            
            checkField(calldataload(add(_pubSignals, 64)))
            
            checkField(calldataload(add(_pubSignals, 96)))
            
            checkField(calldataload(add(_pubSignals, 128)))
            
            checkField(calldataload(add(_pubSignals, 160)))
            
            checkField(calldataload(add(_pubSignals, 192)))
            
            checkField(calldataload(add(_pubSignals, 224)))
            
            checkField(calldataload(add(_pubSignals, 256)))
            
            checkField(calldataload(add(_pubSignals, 288)))
            
            checkField(calldataload(add(_pubSignals, 320)))
            
            checkField(calldataload(add(_pubSignals, 352)))
            
            checkField(calldataload(add(_pubSignals, 384)))
            
            checkField(calldataload(add(_pubSignals, 416)))
            
            checkField(calldataload(add(_pubSignals, 448)))
            
            checkField(calldataload(add(_pubSignals, 480)))
            
            checkField(calldataload(add(_pubSignals, 512)))
            
            checkField(calldataload(add(_pubSignals, 544)))
            
            checkField(calldataload(add(_pubSignals, 576)))
            
            checkField(calldataload(add(_pubSignals, 608)))
            
            checkField(calldataload(add(_pubSignals, 640)))
            
            checkField(calldataload(add(_pubSignals, 672)))
            
            checkField(calldataload(add(_pubSignals, 704)))
            
            checkField(calldataload(add(_pubSignals, 736)))
            
            checkField(calldataload(add(_pubSignals, 768)))
            
            checkField(calldataload(add(_pubSignals, 800)))
            
            checkField(calldataload(add(_pubSignals, 832)))
            
            checkField(calldataload(add(_pubSignals, 864)))
            
            checkField(calldataload(add(_pubSignals, 896)))
            
            checkField(calldataload(add(_pubSignals, 928)))
            
            checkField(calldataload(add(_pubSignals, 960)))
            
            checkField(calldataload(add(_pubSignals, 992)))
            
            checkField(calldataload(add(_pubSignals, 1024)))
            
            checkField(calldataload(add(_pubSignals, 1056)))
            
            checkField(calldataload(add(_pubSignals, 1088)))
            
            checkField(calldataload(add(_pubSignals, 1120)))
            
            checkField(calldataload(add(_pubSignals, 1152)))
            
            checkField(calldataload(add(_pubSignals, 1184)))
            

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }
