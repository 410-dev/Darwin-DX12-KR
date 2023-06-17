# macOS Direct3D 12 Installer

This script utilizes the Game Porting Toolkit, released on macOS 14 Sonoma, to perform all necessary tasks to run Windows games requiring DirectX11, 12 on Rosetta 2.

This script is about 90% automated, and the rest requires direct mouse operation.

한국어 매뉴얼은 이 문서 하단에 있습니다.

<br>

### Supported
✅: Supported
⚠️: Working in progress / Not tested
❌: Not supported
- [✅] Steam
- [⚠️] [W.I.P] Battle.net
- [⚠️] [W.I.P] Epic Games
- [⚠️] [W.I.P] GOG.com

### How to use (without git)

Download the [d3d12script.tar.gz](https://github.com/410-dev/Darwin-DirectX12/releases/download/0.0.2/d3d12script.tar.gz) file from [this link (releases page)](https://github.com/410-dev/Darwin-DirectX12/releases), and extract it.

Open the terminal and enter the following command. At this point, please replace <unzipped folder name> with the name of your unzipped folder.

```bash
cd ~/Downloads/<unzipped folder name>
./main.sh
```

Example:

```bash
cd ~/Downloads/d3d12script
./main.sh
```

Then follow the instructions of the script.

<br>

### How to use (with git commands)

Paste the following command into the terminal.

```bash
git clone https://github.com/410-dev/Darwin-DirectX12.git
cd Darwin-DirectX12
./main.sh
```

Then follow the instructions of the script.



<hr>
# macOS Direct3D 12 Installer

이 스크립트는 macOS 14 Sonoma 에서 발표된 Game Porting Toolkit 을 이용해 Rosetta 2 위에서 DirectX11, 12 를 필요로 하는 Windows 용 게임들을 구동시킬 수 있도록 하는데 필요한 작업들을 일괄로 처리할 수 있도록 만든 스크립트입니다.

이 스크립트는 약 90% 가량 자동화 되어있으며 나머지는 직접적인 마우스 조작이 필요합니다.

<br>

### 지원 여부
✅: 지원됨
⚠️: 작업중 / 테스트 안됨
❌: 지원 안됨
- [✅] Steam
- [⚠️] [작업중] Battle.net
- [⚠️] [작업중] Epic Games
- [⚠️] [작업중] GOG.com

### 사용 방법 (git 사용 없이)

[이 링크](https://github.com/410-dev/Darwin-DirectX12/releases) 에서 [d3d12script.tar.gz](https://github.com/410-dev/Darwin-DirectX12/releases/download/0.0.2/d3d12script.tar.gz) 파일을 다운로드 받고, 압축을 해제합니다.

터미널을 열고 다음 명령어를 입력합니다. 이 때, <압축 해제된 폴더 이름> 은 압축 해제된 폴더 이름으로 바꾸어주세요.

```bash
cd ~/Downloads/<압축 해제된 폴더 이름>
./main-kr.sh
```

예:

```bash
cd ~/Downloads/d3d12script
./main-kr.sh
```

이후 스크립트의 안내에 따르십시오.

<br>

### 사용 방법 (git 명령어 사용)

아래 명령어를 터미널에 붙여넣으십시오.

```bash
git clone https://github.com/410-dev/Darwin-DirectX12.git
cd Darwin-DirectX12
./main-kr.sh
```

이후 스크립트의 안내에 따르십시오.