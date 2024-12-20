export default class Constant {
  static readonly API_DOMAIN: string = "https://interface.music.163.com/eapi/";
  static readonly DOMAIN: string = "https://music.163.com";
  static readonly ENCRYPT: boolean = true;
  static readonly ENCRYPT_RESPONSE: boolean = false;
  static readonly ANIMATION_DURATION: number = 300;
  static readonly COOKIE_EXPIRY_DAYS = 180;
  static readonly DEFAULT_TIMEOUT = 60000;
  static readonly BASE_URL: string = "https://music.hello-world.icu/"
  static readonly DEFAULT_COVER: Resource[] = [
    $r('app.media.109951165422200291'),
    $r('app.media.109951165134386387'),
    $r('app.media.109951164796696795'),
  ]
}

/**
 * Constants for common style.
 */
export class StyleConstants {
  /**
   * Component width percentage: 100%.
   */
  static readonly FULL_WIDTH: string = '100%';
  /**
   * Component height percentage: 100%.
   */
  static readonly FULL_HEIGHT: string = '100%';
  /**
   * Component height percentage: 70%.
   */
  static readonly SEVENTY_HEIGHT: string = '70%';
  /**
   * Component height percentage: 60%.
   */
  static readonly SIXTY_HEIGHT: string = '60%';
  /**
   * Component width percentage: 60%.
   */
  static readonly SIXTY_WIDTH: string = '60%';
  /**
   * Component height percentage: 50%.
   */
  static readonly FIFTY_HEIGHT: string = '50%';
  /**
   * Component height percentage: 50%.
   */
  static readonly HUNDRED_FIFTEEN_WIDTH: string = '115%';
  /**
   * Component space vp : 4.
   */
  static readonly FOUR_SPACE: string = '4vp';
  /**
   * Component space vp : 12.
   */
  static readonly TWELVE_SPACE: string = '12vp';
  /**
   * Component space vp : 14.
   */
  static readonly ITEM_SPACE: string = '14vp';
  /**
   * Component space vp : 15.
   */
  static readonly FIFTEEN_SPACE: string = '15vp';
  /**
   * Font weight value: 700.
   */
  static readonly FONT_WEIGHT_SEVEN: number = 700;
  /**
   * Font weight value: 500.
   */
  static readonly FONT_WEIGHT_FIVE: number = 500;
  /**
   * Font weight value: 400.
   */
  static readonly FONT_WEIGHT_FOUR: number = 400;
  /**
   * Text line value: 2.
   */
  static readonly TWO_TEXT_LINE: number = 2;
  /**
   * Component opacity value: 1.
   */
  static readonly FULL_OPACITY: number = 1;
  /**
   * Component opacity value: 0.6.
   */
  static readonly SIXTY_OPACITY: number = 0.6;
  /**
   * Component opacity value: 0.8.
   */
  static readonly EIGHTY_OPACITY: number = 0.8;
  /**
   * Component layout value: 1.
   */
  static readonly LAYOUT_WEIGHT: number = 1;
  /**
   * Flex basic value: 1.
   */
  static readonly FLEX_BASIC: number = 1;
  /**
   * Flex shrink value: 1.
   */
  static readonly FLEX_SHRINK: number = 1;
  /**
   * Flex grow value: 1.
   */
  static readonly FLEX_GROW: number = 1;
  /**
   * Swiper or list display count value: 1.
   */
  static readonly DISPLAY_ONE: number = 1;
  /**
   * Swiper or list display count value: 2.
   */
  static readonly DISPLAY_TWO: number = 2;
  /**
   * Swiper or list display count value: 3.
   */
  static readonly DISPLAY_THREE: number = 3;
  /**
   * Swiper or list display count value: 4.
   */
  static readonly DISPLAY_FOUR: number = 4;
  /**
   * Image aspect ratio value: 2.23.
   */
  static readonly IMAGE_ASPECT_RATIO: number = 2.25;
  /**
   * Number of value: 0.5.
   */
  static readonly HALF_ONE: number = 0.5;
  /**
   * Number of value: -1.
   */
  static readonly MINUS_ONE: number = -1;
}

export class BreakpointConstants {
  /**
   * Breakpoints that represent small device types.
   */
  static readonly BREAKPOINT_SM: string = 'sm';
  /**
   * Breakpoints that represent middle device types.
   */
  static readonly BREAKPOINT_MD: string = 'md';
  /**
   * Breakpoints that represent large device types.
   */
  static readonly BREAKPOINT_LG: string = 'lg';
  /**
   * Current breakpoints that to query the device types.
   */
  static readonly CURRENT_BREAKPOINT: string = 'currentBreakpoint';
  /**
   * Range of the small device width.
   */
  static readonly RANGE_SM: string = '(320vp<=width<520vp)';
  /**
   * Range of the middle device width.
   */
  static readonly RANGE_MD: string = '(520vp<=width<840vp)';
  /**
   * Range of the large device width.
   */
  static readonly RANGE_LG: string = '(840vp<=width)';
}

export class PageConstants {
  static readonly BUTTON_SPACE: string = '6vp';
}