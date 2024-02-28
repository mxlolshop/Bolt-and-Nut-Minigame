<template>
	<div id="container" v-if="NuiOpen" :style="position_nui">
		<div id="notify" v-if="notify!==''">
			<p :style="success === 1 ? 'background-color: rgba(36, 204, 50, 0.5); ' : 'background-color: rgba(204, 36, 36, 0.5); '">{{notify}}</p>
		</div>
		<div :style="notify!== '' ? 'opacity:0.5' : ''" @click="dropBolt" id="dropBolt" ref="dropBolt">
			<img ref="nut" :style="nutStyle" src="img/nut.png" />
			<img ref="bolt" :style="boltStyle" :src="imageP" />
		</div>
	</div>
</template>

<script>
export default {
	data() {
		return {
			position_nui: 'left: 50%; top: 50%; transform: translate(-50%, -50%);',
			speed: 1.0,

			NameResource: '',
			NuiOpen: false,
			Config: {},
			translate: {},

			notify: '',
			success: 0,
			imageP: 'img/bolt.png',
			isScrewing: false,
			boltDirection: 1,
			isDropping: false,
			animationFrameId: null,

			nutStyle: {
				position: "absolute",
				top: "70vh",
				left: "27vh",
				width: "6vh",
				height: "6vh",
				borderRadius: "0%",
				backgroundColor: "",
				zIndex: 999,

			},

			boltStyle: {
				position: "absolute",
				top: "0vh",
				left: "0vh",
				width: "20vh",
				height: "20vh",
				backgroundColor: "",
				transform: "rotate(0deg) ", 
				filter: "drop-shadow(0px 0px 5px rgba(0, 0, 0, 0.5))",
			},
		};
	},

	created: function () {
        window.addEventListener("message", this.receiveLua);
        window.addEventListener('keydown', this.keyPress);
    },

    destroyed: function () {
        window.removeEventListener("message", this.receiveLua);
        window.removeEventListener('keydown', this.keyPress);
    },

	methods: {
		keyPress: function(event){
            const key = event.key;
            if (key == 'Escape' || key == 'Backspace') {
                this.exitGame();
            }
        },

        receiveLua: function (event) {
            if (!event || !event.data) return;

            const lua = event.data;

            if(lua.ui == "open") {
                this.NuiOpen = lua.NuiOpen;

                if (lua.NuiOpen) {
                    this.NameResource = lua.NameResource;
                    this.Config = lua.Config;
                    this.translate = lua.translate;

					if (this.Config.nutPosition === 1)
						this.nutStyle.top = "40vh";
					else if (this.Config.nutPosition === 2)
						this.nutStyle.top = "50vh";
					else if (this.Config.nutPosition === 3)
						this.nutStyle.top = "60vh";
					else if (this.Config.nutPosition === 4)
						this.nutStyle.top = "70vh";

					this.speed = this.Config.SPEED;
					this.position_nui = 'left: '+this.Config.X+'%; top: '+this.Config.Y+'%; transform: translate(-'+this.Config.X+'%, -'+this.Config.Y+'%);'

					this.resetGame(false);
					this.moveBolt();
                }
            } 
        },

		exitGame() {
			fetch(`https://${this.NameResource}/CloseNui`, {
                method: 'POST',
                body: JSON.stringify({
                    game: this.success,
                }),
            });
		},

		gameFinish(gameResult) {
			fetch(`https://${this.NameResource}/gameFinish`, {
                method: 'POST',
                body: JSON.stringify({
                    game: gameResult,
                }),
            });
		},

		resetGame(exit) {
			if(exit)
				this.exitGame()

			cancelAnimationFrame(this.animationFrameId);
			this.boltStyle.top = "0vh";
			this.boltStyle.left = "0vh";
			this.isDropping = false;
			this.isScrewing = false;
			this.boltStyle.filter = '';
			this.boltStyle.transform = 'rotate(0deg)';
			
			this.boltDirection = 1;

			this.notify = '';
			this.success = -1;
		},

		moveBolt() {
			const self = this;
			const leftLimit = -5;
			const rightLimit = 45;
			const movementSpeed = this.speed;
			let boltPosition = parseInt(this.boltStyle.left); 

			function animate() {
				if (!self.isDropping) {
					boltPosition += movementSpeed * self.boltDirection;

					if (boltPosition >= rightLimit) {
						boltPosition = rightLimit;
						self.boltDirection *= -1;
					} else if (boltPosition <= leftLimit) {
						boltPosition = leftLimit;
						self.boltDirection *= -1;
					}

					self.boltStyle.left = boltPosition + "vh";
				}

				self.animationFrameId = requestAnimationFrame(animate);
			}
			animate();
		},

		dropBolt() {
			if (this.isDropping) return;

			this.isDropping = true;
			this.imageP = 'img/bolt.gif';

			let interval = setInterval(() => {
				const nut = this.$refs.nut.getBoundingClientRect();
				const bolt = this.$refs.bolt.getBoundingClientRect();

				const nutCenterX = nut.left + nut.width / 2;
				const hitMargin = (nut.width / 6);

				const windowHeight = window.innerHeight;
				const descendAfterNut = windowHeight * -0.15; 

				const isHorizontallyAligned = bolt.left + bolt.width / 2 >= nutCenterX - hitMargin &&
					bolt.left + bolt.width / 2 <= nutCenterX + hitMargin;

				if (bolt.top > nut.bottom + descendAfterNut) {
					clearInterval(interval);

					if (isHorizontallyAligned) {
						this.boltStyle.filter = 'drop-shadow(0px 0px 5px rgba(0, 255, 0, 1))'; // verde
						this.notify = this.translate.SUCCESS;
						this.success = 1;
						this.gameFinish(true);

						setTimeout(() => {
							this.resetGame(true);
						}, 2000);
					} else {
						this.boltStyle.transform = 'rotate(0deg)';
						this.boltStyle.filter = 'drop-shadow(0px 0px 5px rgba(255, 0, 0, 1))'; // vermelho
						this.notify = this.translate.FAILED;
						this.success = 0;
						this.gameFinish(false);
						
						setTimeout(() => {
							this.resetGame(true);
						}, 2000);
					}
					this.imageP = 'img/bolt.png';
					return;
				}

				if (bolt.top + bolt.height >= nut.top + 25.0 && !isHorizontallyAligned) {
					clearInterval(interval);
					this.boltStyle.transform = 'rotate(0deg)';
					this.boltStyle.filter = 'drop-shadow(0px 0px 5px rgba(255, 0, 0, 1))'; // vermelho
					this.imageP = 'img/bolt.png';
					this.notify = this.translate.FAILED;
					this.success = 0;
					this.gameFinish(false);
					
					setTimeout(() => {
						this.resetGame(true);
					}, 2000);
					return;
				}
				this.boltStyle.top = parseInt(this.boltStyle.top) + 2 + "px";
			}, 10);
		}
	},
};
</script>

<style>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    list-style: none;
    font-weight: bold;
}

body {
    user-select: none;
	/* background-image: url(https://www.maistecnologia.com/wp-content/uploads/2020/06/fivem-uma-alternativa-ao-gta-online-www.maistecnologia.com.jpg); */
}

#container{
    position:absolute;
	top: 0%;
	left: 0%;
	transform: translate(-0%, -0%);
}

#dropBolt {
	position: relative;
	background-color: rgba(0, 0, 0, 0.5); 
	width: 60vh; 
	height: 80vh;
	border-radius: 2vh;

	overflow-y: hidden;
    overflow-x: hidden;
}

#notify {
	position: absolute;

	width: 100%;
	height: 100%;

	display: flex;
	flex-direction: column;
	justify-content: center;
	align-items: center;
	z-index: 9999;
}

#notify p {
	font-family: "Anta", sans-serif;
    font-weight: 400;
    font-style: normal;
    color: white;
    font-size: 1.5vh;
    border-radius: .5vh;
    padding: 1vh 2vh;
    text-shadow: 0.1vh 0.1vh 0.5vh rgb(0, 0, 0, .9);

	opacity: 0;
    transform: scale(2);
	
    animation: fadeIn 0.75s linear both;
}

@-webkit-keyframes fadeIn {
    to {
        opacity: 1;
        transform: scale(1);
    }
}
</style>